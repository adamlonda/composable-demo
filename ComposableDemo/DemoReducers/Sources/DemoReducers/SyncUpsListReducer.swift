import ComposableArchitecture
import DemoModels
import DemoStorage
import Foundation
import Tagged

@Reducer public struct SyncUpsListReducer {

    @ObservableState public struct State: Equatable {
        @Shared(.syncUps) public var syncUps: IdentifiedArrayOf<SyncUp> = []
        @Presents public var addSyncUp: SyncUpFormReducer.State?

        public init() {}

        public init(syncUps: IdentifiedArrayOf<SyncUp>) {
            self.syncUps = syncUps
        }
    }

    public enum Action {
        case addSyncUpButtonTapped
        case addSyncUp(PresentationAction<SyncUpFormReducer.Action>)
        case confirmAddButtonTapped
        case discardButtonTapped
        case onDelete(IndexSet)
        case syncUpTapped(id: SyncUp.ID)
    }

    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addSyncUpButtonTapped:
                state.addSyncUp = SyncUpFormReducer.State(syncUp: SyncUp(id: SyncUp.ID(uuid())))
                return .none
            case .addSyncUp:
                return .none
            case .confirmAddButtonTapped:
                guard let newSyncUp = state.addSyncUp?.syncUp else { return .none }
                state.addSyncUp = nil
                state.syncUps.append(newSyncUp)
                return .none
            case .discardButtonTapped:
                state.addSyncUp = nil
                return .none
            case let .onDelete(indexSet):
                state.syncUps.remove(atOffsets: indexSet)
                return .none
            case .syncUpTapped:
                return .none
            }
        }
        .ifLet(\.$addSyncUp, action: \.addSyncUp) {
            SyncUpFormReducer()
        }
    }
}
