import DemoModels
import Foundation
import IdentifiedCollections
import Tagged

extension Attendee {

    public static var blob: Self {
        .init(
            id: Attendee.ID(),
            name: "Blob"
        )
    }

    public static var blobJr: Self {
        .init(
            id: Attendee.ID(),
            name: "Blob Jr."
        )
    }

    public static var blobSr: Self {
        .init(
            id: Attendee.ID(),
            name: "Blob Sr."
        )
    }
}

extension IdentifiedArrayOf<Attendee> {

    public static var mock: Self {
        [
            .blob,
            .blobJr,
            .blobSr
        ]
    }
}
