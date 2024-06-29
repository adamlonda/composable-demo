import ComposableArchitecture
import DemoModels

@Reducer public struct AppFeatureReducer {

    @Reducer public enum Path {
        case detail(SyncUpDetailReducer)
        case meeting(Meeting, syncUp: SyncUp)
        case record(RecordMeetingReducer)
    }

    @ObservableState public struct State: Equatable {
        public var path = StackState<Path.State>()
        public var syncUpsList = SyncUpsListReducer.State()

        public init() {}

        public static func == (lhs: AppFeatureReducer.State, rhs: AppFeatureReducer.State) -> Bool {
            lhs.path.ids == rhs.path.ids && lhs.syncUpsList == rhs.syncUpsList
        }
    }

    public enum Action {
        case path(StackActionOf<Path>)
        case syncUpsList(SyncUpsListReducer.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.syncUpsList, action: \.syncUpsList) {
            SyncUpsListReducer()
        }
        Reduce { _, action in
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
