import CoreData
import SwiftData

extension NSManagedObjectID {
    func persistentIdentifier() throws -> PersistentIdentifier {
        let json = PersistentIdentifierJSON(
            implementation: .init(
                primaryKey: uriRepresentation().lastPathComponent,
                uriRepresentation: uriRepresentation(),
                isTemporary: isTemporaryID,
                entityName: entity.name
            )
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(json)
        return try decoder.decode(PersistentIdentifier.self, from: data)
    }
}

private struct PersistentIdentifierJSON: Codable {
    struct Implementation: Codable {
        var primaryKey: String
        var uriRepresentation: URL
        var isTemporary: Bool
        var entityName: String?
    }

    var implementation: Implementation
}
