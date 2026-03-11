import Foundation
import SwiftData

@Model
final class WashRecord {
    var id: UUID
    var date: Date
    var washType: WashType
    var clothingItem: ClothingItem?

    init(date: Date = Date(), washType: WashType, clothingItem: ClothingItem? = nil) {
        self.id = UUID()
        self.date = date
        self.washType = washType
        self.clothingItem = clothingItem
    }
}
