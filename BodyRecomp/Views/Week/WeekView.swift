import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allLogs: [DailyLog]
    @Query private var plans: [MealPlan]

    @State private var viewModel = WeekViewModel()

    private var activePlan: MealPlan? { plans.first(where: { $0.isActive }) }

    private var weekLogs: [DailyLog] {
        let days = viewModel.weekDays
        return allLogs.filter { log in
            days.contains(where: { Calendar.current.isDate($0, inSameDayAs: log.date) })
        }
    }

    private var todayLog: DailyLog? {
        allLogs.first(where: { Calendar.current.isDateInToday($0.date) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    WeekSummaryBanner(
                        logs: weekLogs,
                        targetProtein: activePlan?.targetProteinG ?? 175,
                        targetCalories: activePlan?.targetCal ?? 2050,
                        viewModel: viewModel
                    )
                    .padding(.horizontal)

                    // Today snapshot
                    if let log = todayLog, let plan = activePlan {
                        TodaySnapshotCard(log: log, plan: plan)
                            .padding(.horizontal)
                    }

                    // Day grid
                    VStack(spacing: 0) {
                        Text("This Week")
                            .sectionHeader()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            ForEach(viewModel.weekDays, id: \.self) { day in
                                DayStatusCell(
                                    date: day,
                                    log: viewModel.log(for: day, from: weekLogs),
                                    isToday: Calendar.current.isDateInToday(day)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Weekly stats
                    if !weekLogs.isEmpty {
                        weekStatsSection
                    } else {
                        emptyStateView
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle(viewModel.weekRangeLabel)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var weekStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Week Averages")
                .sectionHeader()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if let avg = viewModel.avgProtein(logs: weekLogs) {
                        StatPill(label: "Protein", value: "\(Int(avg))g", color: .proteinColor)
                    }
                    if let avg = viewModel.avgCalories(logs: weekLogs) {
                        StatPill(label: "Calories", value: "\(Int(avg))", color: .calorieColor)
                    }
                    if let avg = viewModel.avgSleep(logs: weekLogs) {
                        StatPill(label: "Sleep", value: String(format: "%.1f", avg), color: .sleepColor)
                    }
                    if let avg = viewModel.avgEnergy(logs: weekLogs) {
                        StatPill(label: "Energy", value: String(format: "%.1f", avg), color: .energyColor)
                    }
                    StatPill(
                        label: "Sessions",
                        value: "\(viewModel.sessionsCompleted(logs: weekLogs))/5",
                        color: .brandGreen
                    )
                    let shakeRate = viewModel.shakeCompletionRate(logs: weekLogs)
                    StatPill(
                        label: "Shake",
                        value: "\(Int(shakeRate * 100))%",
                        color: shakeRate >= 1.0 ? .brandGreen : .brandOrange
                    )
                }
                .padding(.horizontal)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Your week fills in as you log meals, workouts, and sleep in their tabs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
    }
}
