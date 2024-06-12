import ComposableArchitecture
@testable import ComposableDemo
import XCTest

final class AppFeatureTests: XCTestCase {

    @MainActor func testDelete() async throws {
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr."),
                Attendee(id: Attendee.ID(), name: "Blob Sr.")
            ],
            title: "Point-Free Morning Sync"
        )
        @Shared(.syncUps) var syncUps: IdentifiedArrayOf<SyncUp> = [syncUp]

        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        guard let sharedSyncUp = $syncUps.elements.first else {
            XCTFail("SyncUp not found")
            return
        }

        await store.send(\.path.push, (id: 0, .detail(SyncUpDetail.State(syncUp: sharedSyncUp)))) {
            $0.path[id: 0] = .detail(SyncUpDetail.State(syncUp: sharedSyncUp))
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
