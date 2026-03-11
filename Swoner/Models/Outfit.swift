import Foundation
import SwiftData

@Model
final class Outfit {
    var id: UUID
    var name: String
    var items: [ClothingItem]
    var occasion: Occasion
    var dateCreated: Date
    var isFavorite: Bool

    init(
        name: String,
        items: [ClothingItem] = [],
        occasion: Occasion = .casual,
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.items = items
        self.occasion = occasion
        self.dateCreated = Date()
        self.isFavorite = isFavorite
    }
}
