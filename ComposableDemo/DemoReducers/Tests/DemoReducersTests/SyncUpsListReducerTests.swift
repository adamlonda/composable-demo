import ComposableArchitecture
import DemoModels
import DemoReducers
import XCTest

class SyncUpsListReducerTests: XCTestCase {

    @MainActor func testAddSyncUp_NonExhaustive() async {
        let store = TestStore(initialState: SyncUpsListReducer.State()) {
            SyncUpsListReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off
        // store.exhaustivity = .off(showSkippedAssertions: true)

        await store.send(.addSyncUpButtonTapped)

        let editedSyncUp = SyncUp(
            id: SyncUp.ID(UUID(0)),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr.")
            ],
            title: "Point-Free morning sync"
        )

        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp)

        await store.send(.confirmAddButtonTapped) {
            $0.syncUps = [editedSyncUp]
        }
    }

    @MainActor func testAddSyncUp() async {
        let store = TestStore(initialState: SyncUpsListReducer.State()) {
            SyncUpsListReducer()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addSyncUpButtonTapped) {
            $0.addSyncUp = SyncUpFormReducer.State(syncUp: SyncUp(id: SyncUp.ID(UUID(0))))
        }

        let editedSyncUp = SyncUp(
            id: SyncUp.ID(UUID(0)),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr.")
            ],
            title: "Point-Free morning sync"
        )

        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp) {
            $0.addSyncUp?.syncUp = editedSyncUp
        }

        await store.send(.confirmAddButtonTapped) {
            $0.addSyncUp = nil
            $0.syncUps = [editedSyncUp]
        }
    }

    @MainActor func testDeletion() async {
        let store = TestStore(
            initialState: SyncUpsListReducer.State(
                syncUps: [
                    SyncUp(
                        id: SyncUp.ID(),
                        title: "Point-Free Morning Sync"
                    )
                ]
            )
        ) {
            SyncUpsListReducer()
        }

        await store.send(.onDelete([0])) {
            $0.syncUps = []
        }
    }
}
