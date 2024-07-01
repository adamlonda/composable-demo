import Combine
import ComposableArchitecture
import DemoModels
import Foundation
import SwiftData

#warning("TODO: Make this implementation generic ❔")
public final class SyncUpsPersistenceKey: PersistenceKey {

    private let container: ModelContainer

    public init() throws {
        self.container = try ModelContainer(for: SyncUpStorageModel.self)
    }

    public var id: AnyHashable {
        container.schema.hashValue
    }

    @MainActor public func save(_ value: IdentifiedArrayOf<SyncUp>) {
        let context = container.mainContext
        value.forEach {
            context.insert(SyncUpStorageModel(from: $0))
        }
        try? context.save()
    }

    @MainActor public func load(initialValue: IdentifiedArrayOf<SyncUp>?) -> IdentifiedArrayOf<SyncUp>? {
        let context = container.mainContext
        let fetchedData = try? context.fetch(FetchDescriptor<SyncUpStorageModel>())

        if let fetchedData = fetchedData {
            return IdentifiedArrayOf(uniqueElements: fetchedData.map(SyncUp.init(from:)))
        } else {
            return initialValue
        }
    }

    @MainActor public func subscribe(
        initialValue: IdentifiedArrayOf<SyncUp>?,
        didSet: @Sendable @escaping (_ newValue: IdentifiedArrayOf<SyncUp>?) -> Void
    ) -> Shared<IdentifiedArrayOf<SyncUp>>.Subscription {
        var cancellables = Set<AnyCancellable>()
        let context = container.mainContext

        NotificationCenter.default
            .publisher(for: ModelContext.didSave, object: context)
            .sink { [weak self] _ in
                didSet(self?.load(initialValue: initialValue))
            }
            .store(in: &cancellables)

        return Shared<IdentifiedArrayOf<SyncUp>>.Subscription {
            cancellables.removeAll()
        }
    }
}

extension PersistenceReaderKey where Self == SyncUpsPersistenceKey {

    public static func syncUpsStorage() throws -> Self {
        try SyncUpsPersistenceKey()
    }
}
