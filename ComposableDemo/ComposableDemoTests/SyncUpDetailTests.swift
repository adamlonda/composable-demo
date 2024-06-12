import ComposableArchitecture
@testable import ComposableDemo
import XCTest

class SyncUpDetailTests: XCTestCase {

    @MainActor func testEdit() async {
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            title: "Point-Free Morning Sync"
        )
        let store = TestStore(initialState: SyncUpDetail.State(syncUp: Shared(syncUp))) {
            SyncUpDetail()
        }

        await store.send(.editButtonTapped) {
            $0.destination = .edit(SyncUpForm.State(syncUp: syncUp))
        }

        var editedSyncUp = syncUp
        editedSyncUp.title = "Point-Free Evening Sync"

        await store.send(\.destination.edit.binding.syncUp, editedSyncUp) {
            $0.destination?.edit?.syncUp = editedSyncUp
        }

        await store.send(.doneEditingButtonTapped) {
            $0.destination = nil
            $0.syncUp = editedSyncUp
        }
    }

    @MainActor func testDelete() async {
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            title: "Point-Free Morning Sync"
        )
        let store = TestStore(initialState: SyncUpDetail.State(syncUp: Shared(syncUp))) {
            SyncUpDetail()
        }

        await store.send(.deleteButtonTapped) {
            $0.destination = .alert(.deleteSyncUp)
        }

        await store.send(.destination(.presented(.alert(.confirmButtonTapped)))) {
            $0.destination = nil
        }
    }
}
