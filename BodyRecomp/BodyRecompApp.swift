import SwiftUI
import SwiftData

@main
struct BodyRecompApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            MealPlan.self,
            Meal.self,
            MealItem.self,
            DailyAddition.self,
            TrainingSession.self,
            Exercise.self,
            DailyLog.self,
            SleepChecklist.self,
            MealLog.self,
            DeviationLog.self,
            AdditionLog.self,
            SessionLog.self,
            SetLog.self,
            WeeklyAudit.self,
            PlanHistory.self,
            Favorites.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentRoot()
                .modelContainer(container)
        }
    }
}

// MARK: - Root wrapper that runs seed on first appearance

struct ContentRoot: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RootTabView()
            .task {
                if SeedGuard.needsSeed {
                    SeedData.seedAll(context: modelContext)
                    SeedGuard.markSeeded()
                }
            }
    }
}
