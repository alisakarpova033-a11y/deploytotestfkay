import Foundation
import SwiftData

@Model
final class ClothingItem {
    var id: UUID
    var name: String
    var category: ClothingCategory
    var colorName: String
    var brand: String
    var imageData: Data?
    var dateAdded: Date
    var lastWashed: Date?
    var washCount: Int
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \WashRecord.clothingItem)
    var washRecords: [WashRecord]

    @Relationship
    var outfits: [Outfit]

    init(
        name: String,
        category: ClothingCategory,
        colorName: String = "",
        brand: String = "",
        imageData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.colorName = colorName
        self.brand = brand
        self.imageData = imageData
        self.dateAdded = Date()
        self.lastWashed = nil
        self.washCount = 0
        self.notes = notes
        self.washRecords = []
        self.outfits = []
    }

    var daysSinceLastWash: Int? {
        guard let lastWashed else { return nil }
        return Calendar.current.dateComponents([.day], from: lastWashed, to: Date()).day
    }
}
