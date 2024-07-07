import DemoModels
import Foundation

extension Meeting {

    public static func mock() -> Self {
        .init(
            id: Meeting.ID(),
            date: Date(),
            transcript: ""
        )
    }
}
