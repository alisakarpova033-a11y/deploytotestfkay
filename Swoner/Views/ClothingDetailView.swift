import SwiftUI
import SwiftData

struct ClothingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let item: ClothingItem
    @State private var showingWashSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorFromName(item.colorName).opacity(0.15))
                            .frame(height: 180)

                        VStack(spacing: 12) {
                            Image(systemName: item.category.iconName)
                                .font(.system(size: 56, weight: .ultraLight))
                                .foregroundStyle(colorFromName(item.colorName).opacity(0.6))

                            Text(item.category.displayName.uppercased())
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(item.name)
                                .font(.title3.weight(.medium))
                            Spacer()
                            if !item.colorName.isEmpty {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(colorFromName(item.colorName))
                                        .frame(width: 10, height: 10)
                                    Text(item.colorName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        if !item.brand.isEmpty {
                            Text(item.brand)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if !item.notes.isEmpty {
                            Text(item.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LAUNDRY")
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(1.5)
                                    .foregroundStyle(.secondary)

                                if let days = item.daysSinceLastWash {
                                    Text("\(days) days since wash")
                                        .font(.subheadline)
                                } else {
                                    Text("Never washed")
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(item.washCount)")
                                    .font(.title2.weight(.medium))
                                    .foregroundStyle(.indigo)
                                Text("washes")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Button {
                            showingWashSheet = true
                        } label: {
                            Text("Mark as Washed")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.indigo)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PressableButtonStyle())

                        if !item.washRecords.isEmpty {
                            Divider()

                            Text("HISTORY")
                                .font(.system(size: 9, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)

                            let sorted = item.washRecords.sorted { $0.date > $1.date }
                            ForEach(sorted.prefix(5)) { record in
                                HStack {
                                    Text(record.washType.displayName)
                                        .font(.caption)
                                    Spacer()
                                    Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        HStack {
                            Text("Added \(item.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingWashSheet) {
                WashSheetView(item: item)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct WashSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let item: ClothingItem
    @State private var selectedType: WashType = .machine

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "bubbles.and.sparkles.fill")
                    .font(.system(size: 40, weight: .ultraLight))
                    .foregroundStyle(.indigo)

                Text("Record Wash")
                    .font(.title3.weight(.medium))

                Picker("Wash Type", selection: $selectedType) {
                    ForEach(WashType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Button {
                    recordWash()
                } label: {
                    Text("Confirm")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 30)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func recordWash() {
        let record = WashRecord(washType: selectedType, clothingItem: item)
        modelContext.insert(record)
        item.washRecords.append(record)
        item.lastWashed = Date()
        item.washCount += 1
        dismiss()
    }
}
