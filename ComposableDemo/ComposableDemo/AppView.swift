import ComposableArchitecture
@preconcurrency import DemoModels
import DemoReducers
import SwiftUI

#warning("TODO: Move Views into separate package 💡")

// MARK: - View

struct AppView: View {

    @Bindable var store: StoreOf<AppFeatureReducer>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            SyncUpsListView(
                store: store.scope(state: \.syncUpsList, action: \.syncUpsList)
            )
        } destination: { store in
            switch store.case {
            case let .detail(detailStore):
                SyncUpDetailView(store: detailStore)
            case let .meeting(meeting, syncUp: syncUp):
                MeetingView(meeting: meeting, syncUp: syncUp)
            case let .record(recordStore):
                RecordMeetingView(store: recordStore)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Shared(.syncUps) var syncUps = [
        SyncUp(
            id: SyncUp.ID(),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr"),
                Attendee(id: Attendee.ID(), name: "Blob Sr")
            ],
            duration: .seconds(6),
            meetings: [],
            theme: .orange,
            title: "Morning Sync"
        )
    ]

    return AppView(
        store: Store(
            initialState: AppFeatureReducer.State()
        ) {
            AppFeatureReducer()
        }
    )
}
