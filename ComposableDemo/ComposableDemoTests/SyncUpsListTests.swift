
import ComposableArchitecture
@testable import ComposableDemo
import XCTest


class SyncUpsListTests: XCTestCase {

    @MainActor func testDeletion() async {
        let store = TestStore(
            initialState: SyncUpsList.State(
                syncUps: [
                    SyncUp(
                        id: SyncUp.ID(),
                        title: "Point-Free Morning Sync"
                    )
                ]
            )
        ) {
            SyncUpsList()
        }

        await store.send(.onDelete([0])) {
            $0.syncUps = []
        }
    }
}
