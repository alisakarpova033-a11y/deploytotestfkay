import Foundation

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case top
    case bottom
    case shoes
    case accessories
    case outerwear
    case underwear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .top: "Top"
        case .bottom: "Bottom"
        case .shoes: "Shoes"
        case .accessories: "Accessories"
        case .outerwear: "Outerwear"
        case .underwear: "Underwear"
        }
    }

    var iconName: String {
        switch self {
        case .top: "tshirt.fill"
        case .bottom: "figure.walk"
        case .shoes: "shoe.fill"
        case .accessories: "eyeglasses"
        case .outerwear: "cloud.snow.fill"
        case .underwear: "tshirt"
        }
    }
}

enum WashType: String, Codable, CaseIterable, Identifiable {
    case machine
    case hand
    case dryClean

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .machine: "Machine Wash"
        case .hand: "Hand Wash"
        case .dryClean: "Dry Clean"
        }
    }
}

enum Occasion: String, Codable, CaseIterable, Identifiable {
    case casual
    case work
    case sport
    case party
    case date
    case travel

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .casual: "Casual"
        case .work: "Work"
        case .sport: "Sport"
        case .party: "Party"
        case .date: "Date"
        case .travel: "Travel"
        }
    }
}
