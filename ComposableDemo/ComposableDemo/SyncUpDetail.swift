import ComposableArchitecture
import SwiftUI

#warning("TODO: Split Reducers / Views into separate files / packages ❔")

// MARK: - Reducer

@Reducer struct SyncUpDetail {

    @Reducer(state: .equatable) enum Destination {
        case alert(AlertState<Alert>)
        case edit(SyncUpForm)
    }

    @CasePathable enum Alert {
        case confirmButtonTapped
    }

    @ObservableState struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var syncUp: SyncUp
    }

    enum Action {
        case cancelEditButtonTapped
        case deleteButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case doneEditingButtonTapped
        case editButtonTapped
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination(.presented(.alert(.confirmButtonTapped))):
                @Shared(.syncUps) var syncUps: IdentifiedArrayOf<SyncUp> = []
                syncUps.remove(id: state.syncUp.id)
                return .run { _ in await dismiss() }

            case .destination:
                return .none

            case .cancelEditButtonTapped:
                state.destination = nil
                return .none

            case .deleteButtonTapped:
                state.destination = .alert(.deleteSyncUp)
                return .none

            case .doneEditingButtonTapped:
                guard let editedSyncUp = state.destination?.edit?.syncUp else { return .none }
                state.syncUp = editedSyncUp
                state.destination = nil
                return .none

            case .editButtonTapped:
                state.destination = .edit(SyncUpForm.State(syncUp: state.syncUp))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Reducer Convenience

extension AlertState where Action == SyncUpDetail.Alert {

    static let deleteSyncUp = Self {
        TextState("Delete?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmButtonTapped) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this meeting?")
    }
}

// MARK: - View

struct SyncUpDetailView: View {

    @Bindable var store: StoreOf<SyncUpDetail>

    var body: some View {
        Form {
            Section {
                NavigationLink(
                    state: AppFeature.Path.State.record(RecordMeeting.State(syncUp: store.$syncUp))
                ) {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }

                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text(store.syncUp.duration.formatted(.units()))
                }

                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text(store.syncUp.theme.name)
                        .padding(4)
                        .foregroundColor(store.syncUp.theme.accentColor)
                        .background(store.syncUp.theme.mainColor)
                        .cornerRadius(4)
                }
            } header: {
                Text("Sync-up Info")
            }

            if !store.syncUp.meetings.isEmpty {
                Section {
                    ForEach(store.syncUp.meetings) { meeting in
                        NavigationLink(
                            state: AppFeature.Path.State.meeting(meeting, syncUp: store.syncUp)
                        ) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(meeting.date, style: .date)
                                Text(meeting.date, style: .time)
                            }
                        }
                    }
                } header: {
                    Text("Past meetings")
                }
            }

            Section {
                ForEach(store.syncUp.attendees) { attendee in
                    Label(attendee.name, systemImage: "person")
                }
            } header: {
                Text("Attendees")
            }

            Section {
                Button("Delete") {
                    store.send(.deleteButtonTapped)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar {
            Button("Edit") {
                store.send(.editButtonTapped)
            }
        }
        .navigationTitle(Text(store.syncUp.title))
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .sheet(
            item: $store.scope(state: \.destination?.edit, action: \.destination.edit)
        ) { editSyncUpStore in
            NavigationStack {
                SyncUpFormView(store: editSyncUpStore)
                    .navigationTitle(store.syncUp.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                store.send(.cancelEditButtonTapped)
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                store.send(.doneEditingButtonTapped)
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SyncUpDetailView(
            store: Store(
                initialState: SyncUpDetail.State(
                    syncUp: Shared(
                        SyncUp(
                            id: SyncUp.ID(),
                            attendees: [
                                Attendee(id: Attendee.ID(), name: "Blob"),
                                Attendee(id: Attendee.ID(), name: "Blob Jr."),
                                Attendee(id: Attendee.ID(), name: "Blob Sr.")
                            ],
                            title: "Point-Free Morning Sync"
                        )
                    )
                )
            ) {
                SyncUpDetail()
            }
        )
    }
}
