import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationStack {
            List {
                Section("API Key") {
                    NavigationLink {
                        APIKeyEntryView()
                    } label: {
                        HStack {
                            Label("Anthropic API Key", systemImage: "key.fill")
                            Spacer()
                            Text(KeychainService.hasAPIKey ? "Saved" : "Not set")
                                .font(.caption)
                                .foregroundStyle(KeychainService.hasAPIKey ? .brandGreen : .brandOrange)
                        }
                    }
                }

                Section("Plan") {
                    LabeledContent("Daily calorie target", value: "2,050 kcal")
                    LabeledContent("Protein target", value: "175g")
                    LabeledContent("Daily deficit", value: "~430 kcal")
                }

                #if DEBUG
                Section("Debug") {
                    Button("Reset Onboarding") {
                        hasCompletedOnboarding = false
                    }
                    .foregroundStyle(.brandOrange)

                    Button("Reset Seed (re-seed on next launch)") {
                        SeedGuard.resetForDebug()
                    }
                    .foregroundStyle(.brandRed)
                }
                #endif
            }
            .navigationTitle("Settings")
        }
    }
}
