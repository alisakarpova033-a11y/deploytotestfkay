import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var currentPage = 0
    @State private var showingSettings = false
    @State private var showingAddItem = false

    private let pageLabels = ["Closet", "Outfits", "Calendar"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageIndicator
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                TabView(selection: $currentPage) {
                    ClosetPageView()
                        .tag(0)

                    OutfitsPageView()
                        .tag(1)

                    CalendarPageView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
            .navigationTitle(pageLabels[currentPage])
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.body.weight(.light))
                            .foregroundStyle(.indigo)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.light))
                            .foregroundStyle(.indigo)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddClothingView()
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentPage = index
                    }
                } label: {
                    Text(pageLabels[index])
                        .font(.caption.weight(currentPage == index ? .semibold : .regular))
                        .foregroundStyle(currentPage == index ? .white : .secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            currentPage == index ?
                                AnyShapeStyle(Color.indigo) :
                                AnyShapeStyle(Color(.systemGray6))
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ClothingItem.self, WashRecord.self, Outfit.self], inMemory: true)
}
