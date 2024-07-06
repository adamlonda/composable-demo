import ComposableArchitecture
import DemoModels
import DemoReducers
import SwiftUI

struct SyncUpDetailView: View {

    @Bindable var store: StoreOf<SyncUpDetailReducer>

    // MARK: - Body

    var body: some View {
        Form {
            syncUpInfoSection
            pastMeetingsSection
            attendeesSection
            deleteSection
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
                syncUpForm(editSyncUpStore: editSyncUpStore)
            }
        }
    }

    // MARK: - Sync-Up Info

    @ViewBuilder var syncUpInfoSection: some View {
        Section {
            NavigationLink(
                state: AppFeatureReducer.Path.State.record(RecordMeetingReducer.State(syncUp: store.$syncUp))
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
    }

    // MARK: - Past Meetings

    @ViewBuilder var pastMeetingsSection: some View {
        if !store.syncUp.meetings.isEmpty {
            Section {
                ForEach(store.syncUp.meetings) { meeting in
                    NavigationLink(
                        state: AppFeatureReducer.Path.State.meeting(meeting, syncUp: store.syncUp)
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
    }

    // MARK: - Attendees Section

    @ViewBuilder var attendeesSection: some View {
        Section {
            ForEach(store.syncUp.attendees) { attendee in
                Label(attendee.name, systemImage: "person")
            }
        } header: {
            Text("Attendees")
        }
    }

    // MARK: - Delete Section

    @ViewBuilder var deleteSection: some View {
        Section {
            Button("Delete") {
                store.send(.deleteButtonTapped)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Sync-Up Form

    @ViewBuilder func syncUpForm(editSyncUpStore: StoreOf<SyncUpFormReducer>) -> some View {
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

// MARK: - Previews

#Preview {
    NavigationStack {
        SyncUpDetailView(
            store: Store(
                initialState: SyncUpDetailReducer.State(
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
                SyncUpDetailReducer()
            }
        )
    }
}
