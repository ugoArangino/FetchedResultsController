import Foundation
import SwiftData

@Model
class Item {
    var name: String = UUID().uuidString
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
