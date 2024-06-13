import Foundation
import IdentifiedCollections
import Tagged

public struct SyncUp: Equatable, Identifiable, Codable {
    public let id: Tagged<Self, UUID>
    public var attendees: IdentifiedArrayOf<Attendee>
    public var duration: Duration
    public var meetings: IdentifiedArrayOf<Meeting>
    public var theme: Theme
    public var title: String

    public var durationPerAttendee: Duration {
        duration / attendees.count
    }

    public init(
        id: Tagged<Self, UUID>,
        attendees: IdentifiedArrayOf<Attendee> = [],
        duration: Duration = .seconds(60 * 5),
        meetings: IdentifiedArrayOf<Meeting> = [],
        theme: Theme = .bubblegum,
        title: String = ""
    ) {
        self.id = id
        self.attendees = attendees
        self.duration = duration
        self.meetings = meetings
        self.theme = theme
        self.title = title
    }
}
