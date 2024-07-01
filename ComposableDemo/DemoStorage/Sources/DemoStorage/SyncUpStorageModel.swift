import DemoModels
import Foundation
import SwiftData

#warning("TODO: Finish SyncUp mapping inside & out ‼️")
@Model class SyncUpStorageModel {
    @Attribute(.unique) let id: UUID

    init(id: UUID) {
        self.id = id
    }

    convenience init(from syncUp: SyncUp) {
        self.init(id: syncUp.id.rawValue)
    }
}

extension SyncUp {

    init(from storageModel: SyncUpStorageModel) {
        fatalError("Not implemented 🚧")
    }
}
