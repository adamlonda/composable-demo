import ComposableArchitecture
import DemoModels
@testable import DemoReducers
import XCTest

class SyncUpDetailReducerTests: XCTestCase {

    @MainActor func testEdit() async {
        let syncUp = SyncUp.mock()
        let store = TestStore(initialState: SyncUpDetailReducer.State(syncUp: Shared(syncUp))) {
            SyncUpDetailReducer()
        }

        await store.send(.editButtonTapped) {
            $0.destination = .edit(SyncUpFormReducer.State(syncUp: syncUp))
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
        let syncUp = SyncUp.mock()
        let store = TestStore(initialState: SyncUpDetailReducer.State(syncUp: Shared(syncUp))) {
            SyncUpDetailReducer()
        }

        await store.send(.deleteButtonTapped) {
            $0.destination = .alert(.deleteSyncUp)
        }

        await store.send(.destination(.presented(.alert(.confirmButtonTapped)))) {
            $0.destination = nil
        }
    }
}
