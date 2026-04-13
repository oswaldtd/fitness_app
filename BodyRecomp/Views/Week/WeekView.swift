import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allLogs: [DailyLog]
    @Query private var plans: [MealPlan]

    @State private var viewModel = WeekViewModel()
    @State private var selectedDayForSheet: Date?

    private var activePlan: MealPlan? { plans.first(where: { $0.isActive }) }

    private var weekLogs: [DailyLog] {
        let days = viewModel.weekDays
        return allLogs.filter { log in
            days.contains(where: { Calendar.current.isDate($0, inSameDayAs: log.date) })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    WeekSummaryBanner(
                        logs: weekLogs,
                        targetProtein: activePlan?.targetProteinG ?? 175,
                        viewModel: viewModel
                    )
                    .padding(.horizontal)

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
                                .onTapGesture {
                                    selectedDayForSheet = day
                                }
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
        .sheet(item: $selectedDayForSheet) { day in
            DayDetailSheet(date: day)
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
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Tap any day to log your check-in")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 32)
    }
}

// MARK: - Date: Identifiable for sheet(item:)
extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSince1970 }
}
