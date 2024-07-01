import ComposableArchitecture
import DemoModels
import Foundation
import Tagged

#warning("TODO: Use .syncUpsStorage() instead 💡")
extension PersistenceReaderKey
    where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<SyncUp>>> {

    public static func storage(url: URL) -> Self {
        PersistenceKeyDefault(.fileStorage(url), [])
    }

    public static var syncUps: Self {
        storage(url: .documentsDirectory.appending(component: .syncUps))
    }
}

extension StringProtocol where Self == String {

    public static var syncUps: Self {
        "sync-ups.json"
    }
}
