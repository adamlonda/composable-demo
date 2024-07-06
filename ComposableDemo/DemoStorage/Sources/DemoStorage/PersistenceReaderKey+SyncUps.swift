import ComposableArchitecture
import DemoModels
import Foundation
import Tagged

extension PersistenceReaderKey
    where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<SyncUp>>> {

    public static var syncUps: Self {
        PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "sync-ups.json")), [])
    }
}
