import ComposableArchitecture
import DemoModels

@Reducer public struct SyncUpDetailReducer {

    @Reducer(state: .equatable) public enum Destination {
        case alert(AlertState<Alert>)
        case edit(SyncUpFormReducer)
    }

    @CasePathable public enum Alert {
        case confirmButtonTapped
    }

    @ObservableState public struct State: Equatable {
        @Presents public var destination: Destination.State?
        @Shared public var syncUp: SyncUp

        public init(syncUp: Shared<SyncUp>) {
            self._syncUp = syncUp
        }
    }

    public enum Action {
        case cancelEditButtonTapped
        case deleteButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case doneEditingButtonTapped
        case editButtonTapped
    }

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
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
                state.destination = .edit(SyncUpFormReducer.State(syncUp: state.syncUp))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == SyncUpDetailReducer.Alert {

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
