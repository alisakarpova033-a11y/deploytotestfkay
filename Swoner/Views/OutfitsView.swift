import SwiftUI
import SwiftData

struct OutfitsPageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Outfit.dateCreated, order: .reverse) private var outfits: [Outfit]
    @State private var showingBuilder = false
    @State private var showingGenerator = false

    var body: some View {
        Group {
            if outfits.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        Button {
                            showingGenerator = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "dice")
                                    .font(.subheadline.weight(.light))
                                Text("What to Wear?")
                                    .font(.subheadline.weight(.light))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(.indigo)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.indigo.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.top, 4)

                        LazyVStack(spacing: 8) {
                            ForEach(Array(outfits.enumerated()), id: \.element.id) { index, outfit in
                                OutfitRowCard(outfit: outfit) {
                                    toggleFavorite(outfit)
                                } onDelete: {
                                    modelContext.delete(outfit)
                                }
                                .staggeredAppear(index: index)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingBuilder = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.light))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .indigo.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showingBuilder) {
            OutfitBuilderView()
        }
        .sheet(isPresented: $showingGenerator) {
            OutfitGeneratorView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(.secondary)
            Text("No outfits yet")
                .font(.system(size: 18, weight: .ultraLight))
                .tracking(1)
            Button {
                showingBuilder = true
            } label: {
                Text("Create First Outfit")
                    .font(.caption.weight(.medium))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 8)
            Spacer()
        }
    }

    private func toggleFavorite(_ outfit: Outfit) {
        withAnimation(.easeInOut(duration: 0.2)) {
            outfit.isFavorite.toggle()
        }
    }
}

struct OutfitRowCard: View {
    let outfit: Outfit
    let onFavorite: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                ForEach(outfit.items.prefix(4)) { item in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorFromName(item.colorName).opacity(0.5))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: item.category.iconName)
                                .font(.system(size: 11, weight: .ultraLight))
                                .foregroundStyle(colorFromName(item.colorName))
                        )
                }
                if outfit.items.count > 4 {
                    Text("+\(outfit.items.count - 4)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(outfit.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text("\(outfit.items.count) items")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(outfit.occasion.displayName)
                .font(.system(size: 9, weight: .medium))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(.indigo)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.indigo.opacity(0.08))
                .clipShape(Capsule())

            Button(action: onFavorite) {
                Image(systemName: outfit.isFavorite ? "heart.fill" : "heart")
                    .font(.caption)
                    .foregroundStyle(outfit.isFavorite ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    OutfitsPageView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
