import ComposableArchitecture
import DemoModels
import DemoReducers
import XCTest

class SyncUpFormReducerTests: XCTestCase {

    // MARK: - Add Attendee

    @MainActor func testAddAttendee() async {
        let store = TestStore(
            initialState: SyncUpFormReducer.State(
                syncUp: .mock(attendees: [])
            )
        ) {
            SyncUpFormReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addAttendeeButtonTapped) {
            let attendee = Attendee(id: Attendee.ID(UUID(0)))
            $0.focus = .attendee(attendee.id)
            $0.syncUp.attendees.append(attendee)
        }
    }

    // MARK: - Remove Attendee

    @MainActor func testRemoveAttendee() async {
        let store = TestStore(
            initialState: SyncUpFormReducer.State(
                syncUp: .mock(
                    attendees: [
                        Attendee(id: Attendee.ID()),
                        Attendee(id: Attendee.ID())
                    ]
                )
            )
        ) {
            SyncUpFormReducer()
        }

        await store.send(.onDeleteAttendees([0])) {
            $0.focus = .attendee($0.syncUp.attendees.last!.id)
            $0.syncUp.attendees.removeFirst()
        }
    }

    @MainActor func testRemoveFocusedAttendee() async {
        let attendee1 = Attendee(id: Attendee.ID())
        let attendee2 = Attendee(id: Attendee.ID())

        let store = TestStore(
            initialState: SyncUpFormReducer.State(
                focus: .attendee(attendee1.id),
                syncUp: .mock(attendees: [attendee1, attendee2])
            )
        ) {
            SyncUpFormReducer()
        }

        await store.send(.onDeleteAttendees([0])) {
            $0.focus = .attendee(attendee2.id)
            $0.syncUp.attendees = [attendee2]
        }
    }
}
