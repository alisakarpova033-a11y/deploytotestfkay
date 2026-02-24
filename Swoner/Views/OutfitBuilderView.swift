import SwiftUI
import SwiftData

struct OutfitBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ClothingItem.name) private var allItems: [ClothingItem]

    @State private var name = ""
    @State private var occasion: Occasion = .casual
    @State private var selectedItemIDs: Set<UUID> = []

    private var selectedItems: [ClothingItem] {
        allItems.filter { selectedItemIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !selectedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SELECTED")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(selectedItems) { item in
                                        VStack(spacing: 4) {
                                            ZStack(alignment: .topTrailing) {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(colorFromName(item.colorName).opacity(0.2))
                                                    .frame(width: 56, height: 56)
                                                    .overlay(
                                                        Image(systemName: item.category.iconName)
                                                            .font(.system(size: 20, weight: .ultraLight))
                                                            .foregroundStyle(colorFromName(item.colorName).opacity(0.7))
                                                    )

                                                Button {
                                                    selectedItemIDs.remove(item.id)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundStyle(.white, .secondary)
                                                }
                                                .offset(x: 4, y: -4)
                                            }

                                            Text(item.name)
                                                .font(.system(size: 8))
                                                .lineLimit(1)
                                                .frame(width: 56)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    VStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NAME")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)

                            TextField("Outfit Name", text: $name)
                                .font(.subheadline)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("OCCASION")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(Occasion.allCases) { occ in
                                        Button {
                                            occasion = occ
                                        } label: {
                                            Text(occ.displayName)
                                                .font(.caption.weight(occasion == occ ? .semibold : .regular))
                                                .foregroundStyle(occasion == occ ? .white : .primary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(occasion == occ ? Color.indigo : Color(.systemGray6))
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(ClothingCategory.allCases) { category in
                            let items = allItems.filter { $0.category == category }
                            if !items.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category.displayName.uppercased())
                                        .font(.system(size: 9, weight: .medium))
                                        .tracking(1.5)
                                        .foregroundStyle(.secondary)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(items) { item in
                                                let isSelected = selectedItemIDs.contains(item.id)
                                                Button {
                                                    if isSelected {
                                                        selectedItemIDs.remove(item.id)
                                                    } else {
                                                        selectedItemIDs.insert(item.id)
                                                    }
                                                } label: {
                                                    VStack(spacing: 4) {
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .fill(colorFromName(item.colorName).opacity(0.2))
                                                            .frame(width: 64, height: 64)
                                                            .overlay(
                                                                Image(systemName: item.category.iconName)
                                                                    .font(.system(size: 22, weight: .ultraLight))
                                                                    .foregroundStyle(colorFromName(item.colorName).opacity(0.7))
                                                            )
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 6)
                                                                    .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 2)
                                                            )
                                                            .overlay(alignment: .bottomTrailing) {
                                                                if isSelected {
                                                                    Image(systemName: "checkmark.circle.fill")
                                                                        .font(.system(size: 14))
                                                                        .foregroundStyle(.white, .indigo)
                                                                        .offset(x: 3, y: 3)
                                                                }
                                                            }

                                                        Text(item.name)
                                                            .font(.system(size: 8))
                                                            .foregroundStyle(.primary)
                                                            .lineLimit(1)
                                                            .frame(width: 64)
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("New Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveOutfit()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedItemIDs.isEmpty)
                    .fontWeight(.medium)
                }
            }
        }
    }

    private func saveOutfit() {
        let outfit = Outfit(
            name: name.trimmingCharacters(in: .whitespaces),
            items: selectedItems,
            occasion: occasion
        )
        modelContext.insert(outfit)
        dismiss()
    }
}

#Preview {
    OutfitBuilderView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
