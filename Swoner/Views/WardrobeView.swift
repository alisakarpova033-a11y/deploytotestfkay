import SwiftUI
import SwiftData

struct ClosetPageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var allItems: [ClothingItem]
    @State private var selectedCategory: ClothingCategory?
    @State private var selectedItem: ClothingItem?
    @State private var showLaundryOnly = false

    private var filteredItems: [ClothingItem] {
        var items = allItems
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        if showLaundryOnly {
            items = items.filter { item in
                item.lastWashed == nil || (item.daysSinceLastWash ?? 999) > 7
            }
        }
        return items
    }

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            filterChips
                .padding(.vertical, 8)

            if filteredItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                            ClosetCellView(item: item) {
                                selectedItem = item
                            } onMarkDirty: {
                                markDirty(item)
                            }
                            .staggeredAppear(index: index)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            ClothingDetailView(item: item)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                FilterChipView(title: "All", isSelected: selectedCategory == nil && !showLaundryOnly) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                        showLaundryOnly = false
                    }
                }

                ForEach(ClothingCategory.allCases) { category in
                    FilterChipView(title: category.displayName, isSelected: selectedCategory == category) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showLaundryOnly = false
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }

                FilterChipView(title: "Laundry", isSelected: showLaundryOnly) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                        showLaundryOnly.toggle()
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: showLaundryOnly ? "washer" : "hanger")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(.secondary)
            Text(showLaundryOnly ? "All clean" : "No items yet")
                .font(.system(size: 18, weight: .ultraLight))
                .tracking(1)
            Spacer()
        }
    }

    private func markDirty(_ item: ClothingItem) {
        item.lastWashed = nil
    }
}

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.indigo : Color(.systemGray6))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ClosetCellView: View {
    let item: ClothingItem
    let onTap: () -> Void
    let onMarkDirty: () -> Void

    private var isDirty: Bool {
        item.lastWashed == nil || (item.daysSinceLastWash ?? 999) > 7
    }

    private var swatchColor: Color {
        colorFromName(item.colorName)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(swatchColor.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(swatchColor.opacity(0.3), lineWidth: 1)
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: item.category.iconName)
                                .font(.system(size: 28, weight: .ultraLight))
                                .foregroundStyle(swatchColor.opacity(0.7))
                        )

                    if isDirty {
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .padding(6)
                    }
                }

                Text(item.name)
                    .font(.system(size: 10))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onMarkDirty()
            } label: {
                Label("Mark as Dirty", systemImage: "drop.triangle.fill")
            }
        }
    }
}

func colorFromName(_ name: String) -> Color {
    let lower = name.lowercased().trimmingCharacters(in: .whitespaces)
    switch lower {
    case "red": return .red
    case "blue": return .blue
    case "green": return .green
    case "yellow": return .yellow
    case "orange": return .orange
    case "purple", "violet": return .purple
    case "pink": return .pink
    case "black": return Color(.darkGray)
    case "white": return Color(.lightGray)
    case "gray", "grey": return .gray
    case "brown": return .brown
    case "navy": return Color(red: 0, green: 0, blue: 0.5)
    case "beige", "tan", "cream": return Color(red: 0.9, green: 0.85, blue: 0.7)
    case "teal", "turquoise": return .teal
    case "indigo": return .indigo
    case "coral": return Color(red: 1, green: 0.5, blue: 0.3)
    case "maroon", "burgundy": return Color(red: 0.5, green: 0, blue: 0)
    case "olive", "khaki": return Color(red: 0.5, green: 0.5, blue: 0)
    default: return .indigo
    }
}

#Preview {
    ClosetPageView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
