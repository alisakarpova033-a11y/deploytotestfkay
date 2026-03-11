import SwiftUI
import SwiftData

struct OutfitGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ClothingItem.name) private var allItems: [ClothingItem]

    @State private var generatedItems: [ClothingCategory: ClothingItem] = [:]
    @State private var revealedCategories: Set<ClothingCategory> = []
    @State private var isRevealing = false
    @State private var outfitName = ""
    @State private var occasion: Occasion = .casual
    @State private var showSaveForm = false

    private let generatorCategories: [ClothingCategory] = [.top, .bottom, .shoes, .outerwear]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "dice")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundStyle(.indigo)

                        Text("What to Wear?")
                            .font(.system(size: 20, weight: .ultraLight))
                            .tracking(1)

                        Button {
                            generateOutfit()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "shuffle")
                                    .font(.subheadline.weight(.light))
                                Text(generatedItems.isEmpty ? "Generate" : "Re-Generate")
                                    .font(.subheadline.weight(.medium))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PressableButtonStyle())
                        .disabled(isRevealing)
                        .padding(.horizontal, 16)
                    }

                    VStack(spacing: 8) {
                        ForEach(generatorCategories, id: \.self) { category in
                            if let item = generatedItems[category] {
                                GeneratorItemRow(
                                    item: item,
                                    category: category,
                                    isRevealed: revealedCategories.contains(category)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if !generatedItems.isEmpty && revealedCategories.count == generatedItems.count {
                        saveSection
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var saveSection: some View {
        VStack(spacing: 10) {
            if showSaveForm {
                VStack(spacing: 10) {
                    TextField("Outfit Name", text: $outfitName)
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Occasion.allCases) { occ in
                                Button {
                                    occasion = occ
                                } label: {
                                    Text(occ.displayName)
                                        .font(.caption.weight(occasion == occ ? .semibold : .regular))
                                        .foregroundStyle(occasion == occ ? .white : .primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(occasion == occ ? Color.indigo : Color(.systemGray6))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        saveOutfit()
                    } label: {
                        Text("Save Outfit")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(outfitName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.indigo)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(outfitName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSaveForm = true
                    }
                } label: {
                    Text("Save this Outfit")
                        .font(.subheadline.weight(.medium))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private func generateOutfit() {
        generatedItems = [:]
        revealedCategories = []
        showSaveForm = false
        outfitName = ""
        isRevealing = true

        var picked: [ClothingCategory: ClothingItem] = [:]
        for category in generatorCategories {
            let items = allItems.filter { $0.category == category }
            if let random = items.randomElement() {
                picked[category] = random
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            generatedItems = picked
        }

        let categoriesToReveal = generatorCategories.filter { picked[$0] != nil }
        for (i, category) in categoriesToReveal.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35 + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    revealedCategories.insert(category)
                }
                if i == categoriesToReveal.count - 1 {
                    isRevealing = false
                }
            }
        }

        if categoriesToReveal.isEmpty {
            isRevealing = false
        }
    }

    private func saveOutfit() {
        let items = Array(generatedItems.values)
        let outfit = Outfit(
            name: outfitName.trimmingCharacters(in: .whitespaces),
            items: items,
            occasion: occasion
        )
        modelContext.insert(outfit)
        dismiss()
    }
}

struct GeneratorItemRow: View {
    let item: ClothingItem
    let category: ClothingCategory
    let isRevealed: Bool

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(isRevealed ? colorFromName(item.colorName).opacity(0.2) : Color(.systemGray5))
                .frame(width: 44, height: 44)
                .overlay(
                    Group {
                        if isRevealed {
                            Image(systemName: category.iconName)
                                .font(.system(size: 18, weight: .ultraLight))
                                .foregroundStyle(colorFromName(item.colorName).opacity(0.7))
                        } else {
                            Image(systemName: "questionmark")
                                .font(.body.weight(.light))
                                .foregroundStyle(.secondary)
                        }
                    }
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(isRevealed ? item.name : category.displayName)
                    .font(.subheadline.weight(.medium))
                if isRevealed && !item.brand.isEmpty {
                    Text(item.brand)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                } else if !isRevealed {
                    Text("Generating...")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isRevealed {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.indigo)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

#Preview {
    OutfitGeneratorView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
