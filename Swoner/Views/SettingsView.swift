import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("washNotificationsEnabled") private var washNotificationsEnabled = false
    @AppStorage("washReminderDays") private var washReminderDays = 7

    var body: some View {
        List {
            Section("Appearance") {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                }
                .tint(.indigo)
            }

            Section("Notifications") {
                Toggle(isOn: $washNotificationsEnabled) {
                    Label("Wash Reminders", systemImage: "bell.fill")
                }
                .tint(.indigo)

                if washNotificationsEnabled {
                    Stepper(value: $washReminderDays, in: 1...30) {
                        Label("Remind after \(washReminderDays) days", systemImage: "calendar.badge.clock")
                    }
                }
            }

            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Developer", systemImage: "person.fill")
                    Spacer()
                    Text("Sadyg Sadygov")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Built with", systemImage: "swift")
                    Spacer()
                    Text("SwiftUI + SwiftData")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                } label: {
                    Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
