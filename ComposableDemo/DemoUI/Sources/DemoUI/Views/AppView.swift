import ComposableArchitecture
@preconcurrency import DemoModels
import DemoReducers
import SwiftUI

// MARK: - View

public struct AppView: View {

    @Bindable var store: StoreOf<AppFeatureReducer>

    public init(store: StoreOf<AppFeatureReducer>) {
        self._store = Bindable(store)
    }

    public var body: some View {
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
        .mock(duration: .seconds(6), theme: .orange, title: "Morning Sync")
    ]

    return AppView(
        store: Store(
            initialState: AppFeatureReducer.State()
        ) {
            AppFeatureReducer()
        }
    )
}
