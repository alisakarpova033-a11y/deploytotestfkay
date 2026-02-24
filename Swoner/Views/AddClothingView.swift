import SwiftUI
import SwiftData
import PhotosUI

struct AddClothingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brand = ""
    @State private var category: ClothingCategory = .top
    @State private var colorName = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "camera")
                                    .font(.system(size: 28, weight: .ultraLight))
                                    .foregroundStyle(.indigo)
                                Text("Add Photo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        formField("Name", text: $name)
                        formField("Brand", text: $brand)
                        formField("Color", text: $colorName, placeholder: "e.g. Navy, White, Red")

                        if !colorName.isEmpty {
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(colorFromName(colorName))
                                    .frame(width: 24, height: 24)
                                Text("Preview")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("CATEGORY")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(ClothingCategory.allCases) { cat in
                                        Button {
                                            category = cat
                                        } label: {
                                            VStack(spacing: 4) {
                                                Image(systemName: cat.iconName)
                                                    .font(.body.weight(.light))
                                                Text(cat.displayName)
                                                    .font(.system(size: 9))
                                            }
                                            .foregroundStyle(category == cat ? .white : .primary)
                                            .frame(width: 64, height: 56)
                                            .background(category == cat ? Color.indigo : Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOTES")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)

                            TextField("Optional notes", text: $notes, axis: .vertical)
                                .lineLimit(2...4)
                                .font(.subheadline)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.medium)
                }
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            TextField(placeholder ?? label, text: text)
                .font(.subheadline)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func saveItem() {
        let item = ClothingItem(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            colorName: colorName.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces),
            imageData: imageData,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(item)
        dismiss()
    }
}

#Preview {
    AddClothingView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
