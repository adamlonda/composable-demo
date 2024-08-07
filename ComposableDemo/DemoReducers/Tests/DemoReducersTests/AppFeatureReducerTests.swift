import ComposableArchitecture
@preconcurrency import DemoModels
import DemoModelMocks
@testable import DemoReducers
import XCTest

final class AppFeatureReducerTests: XCTestCase {

    @MainActor func testDelete() async throws {
        let syncUp = SyncUp.mock()
        @Shared(.syncUps) var syncUps = [syncUp]

        let store = TestStore(initialState: AppFeatureReducer.State()) {
            AppFeatureReducer()
        }

        let sharedSyncUp = try XCTUnwrap(Shared($syncUps[id: syncUp.id]))

        await store.send(\.path.push, (id: 0, .detail(SyncUpDetailReducer.State(syncUp: sharedSyncUp)))) {
            $0.path[id: 0] = .detail(SyncUpDetailReducer.State(syncUp: sharedSyncUp))
        }

        await store.send(\.path[id: 0].detail.deleteButtonTapped)
        await store.send(\.path[id: 0].detail.destination.alert.confirmButtonTapped) {
            $0.path[id: 0, case: \.detail]?.destination = nil
            $0.syncUpsList.syncUps = []
        }

        await store.receive(\.path.popFrom) {
            $0.path = StackState()
        }
    }
}
