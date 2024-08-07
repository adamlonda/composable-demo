import ComposableArchitecture
import DemoModels
import Foundation

@Reducer public struct SyncUpFormReducer {

    @ObservableState public struct State: Equatable {
        public var focus: Field? = .title
        public var syncUp: SyncUp

        public init(focus: Field? = .title, syncUp: SyncUp) {
            self.focus = focus
            self.syncUp = syncUp
        }
    }

    public enum Field: Hashable {
        case attendee(Attendee.ID)
        case title
    }

    public enum Action: BindableAction {
        case addAttendeeButtonTapped
        case binding(BindingAction<State>)
        case onDeleteAttendees(IndexSet)
    }

    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .addAttendeeButtonTapped:
                let attendee = Attendee(id: Attendee.ID(uuid()))
                state.syncUp.attendees.append(attendee)
                state.focus = .attendee(attendee.id)
                return .none

            case .binding:
                return .none

            case let .onDeleteAttendees(indices):
                state.syncUp.attendees.remove(atOffsets: indices)
                guard !state.syncUp.attendees.isEmpty, let firstIndex = indices.first else {
                    return .none
                }
                let index = min(firstIndex, state.syncUp.attendees.count - 1)
                state.focus = .attendee(state.syncUp.attendees[index].id)
                return .none
            }
        }
    }
}
