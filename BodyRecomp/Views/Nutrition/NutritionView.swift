import SwiftUI
import SwiftData

struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<MealPlan> { $0.isActive }) private var plans: [MealPlan]
    @Query private var allLogs: [DailyLog]

    @State private var viewModel = NutritionViewModel()
    @State private var weekViewModel = WeekViewModel()
    @State private var showingDeviationSheet = false
    @State private var deviationSlot: MealSlot?

    private var activePlan: MealPlan? { plans.first }

    private var todayLog: DailyLog? {
        allLogs.first(where: { Calendar.current.isDateInToday($0.date) })
    }

    private var currentVariant: DayVariant {
        todayLog?.dayVariant ?? .broccoliDay
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let plan = activePlan {
                        // Macro progress bar
                        if let log = todayLog {
                            MacroProgressBar(
                                log: log,
                                variant: currentVariant,
                                plan: plan,
                                viewModel: viewModel
                            )
                            .padding(.horizontal)
                        }

                        // Day variant picker
                        variantPicker

                        // Meal slots
                        ForEach(viewModel.sortedSlots(), id: \.self) { slot in
                            if let meal = viewModel.mealsForVariant(currentVariant, from: plan)[slot] {
                                MealSlotCard(
                                    meal: meal,
                                    slot: slot,
                                    log: todayLog,
                                    plan: plan,
                                    onDeviation: {
                                        deviationSlot = slot
                                        showingDeviationSheet = true
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }

                        // Gap-closers
                        if let log = todayLog {
                            GapCloserSection(log: log, plan: plan)
                                .padding(.horizontal)
                        }

                    } else {
                        ContentUnavailableView("No meal plan loaded",
                            systemImage: "fork.knife",
                            description: Text("Restart the app to seed your plan."))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDeviationSheet) {
            if let slot = deviationSlot, let log = ensureTodayLog() {
                DeviationSheet(slot: slot, dailyLog: log)
            }
        }
        .onAppear {
            _ = ensureTodayLog()
        }
    }

    private var variantPicker: some View {
        Picker("Day Variant", selection: variantBinding) {
            Text("🥦 Broccoli").tag(DayVariant.broccoliDay)
            Text("🫘 Green Bean").tag(DayVariant.greenBeanDay)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var variantBinding: Binding<DayVariant> {
        Binding(
            get: { currentVariant },
            set: { newVariant in
                let log = ensureTodayLog()
                log.dayVariant = newVariant
            }
        )
    }

    @discardableResult
    private func ensureTodayLog() -> DailyLog {
        weekViewModel.findOrCreate(date: Date(), context: modelContext)
    }
}
