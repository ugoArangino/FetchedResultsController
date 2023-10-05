import Combine
import FetchedResultsController
import Foundation
import SwiftData

@Observable
class ViewModel {
    var items: [Item] = .init()
    var changes: [FetchedResultsControlleChange<Item>] = .init()
    var cancellables: Set<AnyCancellable> = .init()

    let modelContext = ModelContext({
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }())

    init() {
        let fetchedResultsController1 = FetchedResultsController<Item>(modelContext: modelContext)
        let fetchedResultsController2 = FetchedResultsController<Item>(modelContext: modelContext, predicate: #Predicate { item in
            item.name.contains("B")
        })

        items = (try? fetchedResultsController1.fetch()) ?? []

        fetchedResultsController1.anyStoreChange.replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &cancellables)

        fetchedResultsController2.changes.replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.changes, on: self)
            .store(in: &cancellables)
    }

    deinit {
        fatalError()
    }

    func insert() {
        let model = Item(timestamp: .now)
        modelContext.insert(model)
    }

    func delete(_ model: Int) {
        let items: [Item] = try! modelContext.fetch(.init())
        let item = items[model]
        modelContext.delete(item)
    }

    func updateItem(_ item: Item) {
        item.timestamp = .now
    }

    func deleteAll() {
        items.forEach(modelContext.delete)
    }
}
