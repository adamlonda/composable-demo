import DemoModels
import IdentifiedCollections
import Tagged

extension SyncUp {

    public static func mock(id: SyncUp.ID = SyncUp.ID(), attendees: IdentifiedArrayOf<Attendee> = .mock) -> Self {
        .init(
            id: id,
            attendees: attendees,
            title: "Point-Free Morning Sync"
        )
    }

    public static func mock(
        attendees: IdentifiedArrayOf<Attendee> = .mock,
        duration: Duration,
        theme: Theme = .bubblegum,
        title: String = "Point-Free Morning Sync"
    ) -> Self {
        .init(
            id: SyncUp.ID(),
            attendees: attendees,
            duration: duration,
            theme: theme,
            title: title
        )
    }
}
