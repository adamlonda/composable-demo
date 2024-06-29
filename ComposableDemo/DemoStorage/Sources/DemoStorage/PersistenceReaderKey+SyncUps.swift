import ComposableArchitecture
import DemoModels
import Foundation
import Tagged

extension PersistenceReaderKey
    where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<SyncUp>>> {

    public static func syncUps(url: URL) -> Self {
        PersistenceKeyDefault(.fileStorage(url), [])
    }

    public static var syncUps: Self {
        syncUps(url: .documentsDirectory.appending(component: "sync-ups.json"))
    }
}
