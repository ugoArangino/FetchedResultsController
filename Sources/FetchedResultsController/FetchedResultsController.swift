import Combine
import CoreData
import SwiftData

public enum FetchedResultsControllerChangeType: String, CaseIterable, Hashable {
    case inserted
    case updated
    case deleted
}

public struct FetchedResultsControlleChange<T: PersistentModel>: Hashable {
    public let type: FetchedResultsControllerChangeType
    public let model: T
}

extension FetchedResultsControlleChange: Identifiable {
    public var id: ObjectIdentifier {
        model.id
    }
}

@Observable
public class FetchedResultsController<T: PersistentModel> {
    public let anyStoreChange: AnyPublisher<[T], Error>
    public let changes: AnyPublisher<[FetchedResultsControlleChange<T>], Never>

    private let modelContext: ModelContext
    private let fetchDesciptor: FetchDescriptor<T>

    public init(
        modelContext: ModelContext,
        predicate: Predicate<T>? = nil,
        sortDescriptors: [SortDescriptor<T>] = []
    ) {
        let fetchDesciptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortDescriptors)

        self.modelContext = modelContext
        self.fetchDesciptor = fetchDesciptor

        anyStoreChange = NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
            .tryMap { _ in
                try modelContext.fetch(fetchDesciptor)
            }
            .eraseToAnyPublisher()

        changes = NotificationCenter.default
            .publisher(for: Notification.Name.NSManagedObjectContextObjectsDidChange)
            .compactMap { (notification: Notification) in
                guard notification.userInfo?["NSObjectsChangedByMergeChangesKey"] == nil else { return nil }
                guard notification.userInfo?["managedObjectContext"] != nil else { return nil }

                func changes(for changeType: FetchedResultsControllerChangeType) -> [FetchedResultsControlleChange<T>] {
                    guard let managedObjects = notification.userInfo?[changeType.rawValue] as? Set<NSManagedObject> else { return [] }
                    let newModels = managedObjects.compactMap {
                        let persistentIdentifier = try? $0.objectID.persistentIdentifier()
                        return persistentIdentifier.map(modelContext.model) as? T
                    }

                    let changes = try? newModels
                        .filter(predicate ?? #Predicate { _ in true })
                        .map { model in
                            FetchedResultsControlleChange<T>(type: changeType, model: model)
                        }

                    return changes ?? []
                }

                return FetchedResultsControllerChangeType
                    .allCases
                    .flatMap(changes)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func fetch() throws -> [T] {
        try modelContext.fetch(fetchDesciptor)
    }
}
