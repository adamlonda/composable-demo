
import ComposableArchitecture
import SwiftUI

#warning("Split Reducers / Views into separate files / packages ❔")

// MARK: - Reducer

@Reducer struct SyncUpDetail {

    @ObservableState struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
        @Shared var syncUp: SyncUp
        @Presents var editSyncUp: SyncUpForm.State?
    }

    enum Action {
        case alert(PresentationAction<Alert>)
        case cancelEditButtonTapped
        case deleteButtonTapped
        case doneEditingButtonTapped
        case editButtonTapped
        case editSyncUp(PresentationAction<SyncUpForm.Action>)

        @CasePathable enum Alert {
            case confirmButtonTapped
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .alert(.presented(.confirmButtonTapped)):
                    @Shared(.fileStorage(.syncUps)) var syncUps: IdentifiedArrayOf<SyncUp> = []
                    syncUps.remove(id: state.syncUp.id)
                    return .run { _ in await dismiss() }

                case .alert(.dismiss):
                    return .none

                case .cancelEditButtonTapped:
                    state.editSyncUp = nil
                    return .none

                case .deleteButtonTapped:
                    state.alert = .deleteSyncUp
                    return .none

                case .doneEditingButtonTapped:
                    guard let editedSyncUp = state.editSyncUp?.syncUp else { return .none }
                    state.syncUp = editedSyncUp
                    state.editSyncUp = nil
                    return .none

                case .editButtonTapped:
                    state.editSyncUp = SyncUpForm.State(syncUp: state.syncUp)
                    return .none

                case .editSyncUp:
                    return .none
            }
        }
        .ifLet(\.$editSyncUp, action: \.editSyncUp) {
            SyncUpForm()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Reducer Convenience

extension AlertState where Action == SyncUpDetail.Action.Alert {

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
                NavigationLink {
                } label: {
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
                        Button {
                        } label: {
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
        .navigationTitle(Text(store.syncUp.title))
        .toolbar {
            Button("Edit") {
                store.send(.editButtonTapped)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .sheet(item: $store.scope(state: \.editSyncUp, action: \.editSyncUp)) { editSyncUpStore in
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
                                Attendee(id: Attendee.ID(), name: "Blob Sr."),
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
