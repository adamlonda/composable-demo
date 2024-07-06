import ComposableArchitecture
import DemoModels

@Reducer public struct RecordMeetingReducer {

    @ObservableState public struct State: Equatable {
        @Presents public var alert: AlertState<Alert>?
        public var secondsElapsed = 0
        public var speakerIndex = 0
        @Shared public var syncUp: SyncUp
        var transcript = ""

        public init(syncUp: Shared<SyncUp>) {
            self._syncUp = syncUp
        }

        public var durationRemaining: Duration {
            syncUp.duration - .seconds(secondsElapsed)
        }
    }

    public enum Action {
        case alert(PresentationAction<Alert>)
        case endMeetingButtonTapped
        case nextButtonTapped
        case onAppear
        case timerTick
    }

    public enum Alert {
        case discardMeeting
        case saveMeeting
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.discardMeeting)):
                return .run { _ in await dismiss() }
            case .alert(.presented(.saveMeeting)):
                state.syncUp.meetings.insert(
                    Meeting(id: Meeting.ID(uuid()), date: now, transcript: state.transcript),
                    at: 0
                )
                return .run { _ in await dismiss() }
            case .alert:
                return .none
            case .endMeetingButtonTapped:
                state.alert = .endMeeting
                return .none
            case .nextButtonTapped:
                guard state.speakerIndex < state.syncUp.attendees.count - 1 else {
                    state.alert = .endMeeting
                    return .none
                }
                state.speakerIndex += 1
                state.secondsElapsed = state.speakerIndex
                    * Int(state.syncUp.durationPerAttendee.components.seconds)
                return .none
            case .onAppear:
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
            case .timerTick:
                guard state.alert == nil else {
                    return .none
                }
                state.secondsElapsed += 1
                let secondsPerAttendee = Int(state.syncUp.durationPerAttendee.components.seconds)
                if state.secondsElapsed.isMultiple(of: secondsPerAttendee) {
                    if state.secondsElapsed == state.syncUp.duration.components.seconds {
                        state.syncUp.meetings.insert(
                            Meeting(id: Meeting.ID(uuid()), date: now, transcript: state.transcript),
                            at: 0
                        )
                        return .run { _ in await dismiss() }
                    }
                    state.speakerIndex += 1
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension AlertState where Action == RecordMeetingReducer.Alert {
    public static var endMeeting: Self {
        Self {
            TextState("End meeting?")
        } actions: {
            ButtonState(action: .saveMeeting) {
                TextState("Save and end")
            }
            ButtonState(role: .destructive, action: .discardMeeting) {
                TextState("Discard")
            }
            ButtonState(role: .cancel) {
                TextState("Resume")
            }
        } message: {
            TextState("You are ending the meeting early. What would you like to do?")
        }
    }
}
