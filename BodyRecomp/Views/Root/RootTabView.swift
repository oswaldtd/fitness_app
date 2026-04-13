import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        TabView {
            WeekView()
                .tabItem {
                    Label("Week", systemImage: "calendar.badge.checkmark")
                }

            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }

            TrainingView()
                .tabItem {
                    Label("Training", systemImage: "dumbbell.fill")
                }

            SleepView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.zzz.fill")
                }

            AuditView()
                .tabItem {
                    Label("Audit", systemImage: "chart.bar.doc.horizontal")
                }
        }
        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView()
        }
    }
}
