
import ComposableArchitecture
import SwiftUI

#warning("Split Reducers / Views into separate files / packages ❔")

// MARK: - Reducer

@Reducer struct AppFeature {

    @Reducer enum Path {
        case detail(SyncUpDetail)
        case meeting(Meeting, syncUp: SyncUp)
    }

    @ObservableState struct State {
        var path = StackState<Path.State>()
        var syncUpsList = SyncUpsList.State()
    }

    enum Action {
        case path(StackActionOf<Path>)
        case syncUpsList(SyncUpsList.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.syncUpsList, action: \.syncUpsList) {
            SyncUpsList()
        }
        Reduce { state, action in
            switch action {
                case .path:
                    return .none
                case .syncUpsList:
                    return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

// MARK: - View

struct AppView: View {

    @Bindable var store: StoreOf<AppFeature>

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
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    )
}
