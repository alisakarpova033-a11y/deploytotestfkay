import SwiftUI
import SwiftData

struct CalendarPageView: View {
    @Query(sort: \Outfit.dateCreated, order: .reverse) private var allOutfits: [Outfit]
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date?
    @State private var showingOutfitPicker = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private var calendar: Calendar { Calendar.current }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var daysInMonth: [DateComponents] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        return range.map { day in
            var comp = calendar.dateComponents([.year, .month], from: displayedMonth)
            comp.day = day
            return comp
        }
    }

    private var firstWeekday: Int {
        var comp = calendar.dateComponents([.year, .month], from: displayedMonth)
        comp.day = 1
        guard let date = calendar.date(from: comp) else { return 0 }
        return (calendar.component(.weekday, from: date) - calendar.firstWeekday + 7) % 7
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                            selectedDate = nil
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.light))
                            .foregroundStyle(.indigo)
                    }

                    Spacer()

                    Text(monthTitle)
                        .font(.subheadline.weight(.medium))
                        .tracking(1)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                            selectedDate = nil
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.light))
                            .foregroundStyle(.indigo)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(height: 20)
                    }
                }
                .padding(.horizontal, 12)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<firstWeekday, id: \.self) { _ in
                        Color.clear.frame(height: 44)
                    }

                    ForEach(daysInMonth, id: \.day) { comp in
                        let dayNumber = comp.day ?? 0
                        let date = calendar.date(from: comp)
                        let isToday = isTodayDate(comp)
                        let isSelected = isDateSelected(comp)
                        let hasOutfit = date != nil && hasOutfitForDate(date!)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if isSelected {
                                    selectedDate = nil
                                } else {
                                    selectedDate = date
                                }
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(dayNumber)")
                                    .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                                    .foregroundStyle(isSelected ? .white : isToday ? .indigo : .primary)

                                if hasOutfit {
                                    Circle()
                                        .fill(isSelected ? Color.white : Color.indigo)
                                        .frame(width: 4, height: 4)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? Color.indigo : isToday ? Color.indigo.opacity(0.08) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)

                if let selected = selectedDate {
                    selectedDayDetail(for: selected)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    todayOutfitSection
                }
            }
            .padding(.bottom, 20)
        }
    }

    private var todayOutfitSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("TODAY'S OUTFIT")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            let todayOutfit = outfitForDate(Date())
            if let outfit = todayOutfit {
                OutfitDayCard(outfit: outfit)
            } else {
                Text("No outfit planned for today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 12)
    }

    private func selectedDayDetail(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(date.formatted(date: .long, time: .omitted).uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if let outfit = outfitForDate(date) {
                OutfitDayCard(outfit: outfit)
            } else {
                Text("No outfit for this day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 12)
    }

    private func hasOutfitForDate(_ date: Date) -> Bool {
        allOutfits.contains { calendar.isDate($0.dateCreated, inSameDayAs: date) }
    }

    private func outfitForDate(_ date: Date) -> Outfit? {
        allOutfits.first { calendar.isDate($0.dateCreated, inSameDayAs: date) }
    }

    private func isDateSelected(_ comp: DateComponents) -> Bool {
        guard let date = calendar.date(from: comp), let selected = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selected)
    }

    private func isTodayDate(_ comp: DateComponents) -> Bool {
        guard let date = calendar.date(from: comp) else { return false }
        return calendar.isDateInToday(date)
    }
}

struct OutfitDayCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(outfit.name)
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text(outfit.occasion.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.indigo.opacity(0.08))
                    .clipShape(Capsule())
            }

            HStack(spacing: 4) {
                ForEach(outfit.items.prefix(5)) { item in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorFromName(item.colorName).opacity(0.4))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: item.category.iconName)
                                .font(.system(size: 10, weight: .ultraLight))
                                .foregroundStyle(colorFromName(item.colorName))
                        )
                }
                if outfit.items.count > 5 {
                    Text("+\(outfit.items.count - 5)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

#Preview {
    CalendarPageView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
