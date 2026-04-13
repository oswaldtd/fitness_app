import SwiftUI
import SwiftData

struct SleepView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var allLogs: [DailyLog]

    @State private var viewModel = SleepViewModel()
    @State private var weekViewModel = WeekViewModel()
    @State private var todayLog: DailyLog?

    private var checklist: SleepChecklist? {
        guard let log = todayLog else { return nil }
        return log.sleepChecklist
    }

    private var recentLogs: [DailyLog] {
        Array(allLogs.prefix(7))
    }

    private func ensureChecklist() {
        guard let log = todayLog else { return }
        if log.sleepChecklist == nil {
            let c = SleepChecklist()
            c.dailyLog = log
            modelContext.insert(c)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.shouldShowCortisolWarning(recentLogs: recentLogs) {
                        CortisolWarningBanner(
                            message: viewModel.cortisolWarningMessage(recentLogs: recentLogs)
                        )
                        .padding(.horizontal)
                    }

                    // Tonight's checklist
                    if let c = checklist {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Tonight's Protocol")
                                .font(.headline)
                                .padding()

                            Divider().padding(.horizontal)

                            ChecklistRow(
                                title: "Magnesium citrate",
                                subtitle: "300–400mg, 45–60 min before bed",
                                systemImage: "pills.fill",
                                isChecked: Binding(get: { c.magnesiumTaken }, set: { c.magnesiumTaken = $0 })
                            )
                            Divider().padding(.horizontal)
                            ChecklistRow(
                                title: "Pre-bed snack",
                                subtitle: "Greek yogurt + berries",
                                systemImage: "cup.and.saucer.fill",
                                isChecked: Binding(get: { c.preBedSnackEaten }, set: { c.preBedSnackEaten = $0 })
                            )
                            Divider().padding(.horizontal)
                            ChecklistRow(
                                title: "No training last 3 hrs",
                                subtitle: "Raises core temp and cortisol",
                                systemImage: "dumbbell",
                                isChecked: Binding(get: { c.noTrainingLast3hrs }, set: { c.noTrainingLast3hrs = $0 })
                            )
                            Divider().padding(.horizontal)
                            ChecklistRow(
                                title: "Consistent sleep time",
                                subtitle: "Highest-leverage intervention",
                                systemImage: "clock.fill",
                                isChecked: Binding(get: { c.consistentSleepTime }, set: { c.consistentSleepTime = $0 })
                            )
                            Divider().padding(.horizontal)
                            ChecklistRow(
                                title: "Morning light within 30 min",
                                subtitle: "5–10 min outside anchors circadian rhythm",
                                systemImage: "sun.max.fill",
                                isChecked: Binding(get: { c.morningLightWithin30min }, set: { c.morningLightWithin30min = $0 })
                            )
                            Divider().padding(.horizontal)
                            ChecklistRow(
                                title: "Woke at 3am",
                                subtitle: "If this worsens, mention to prescribing doctor",
                                systemImage: "exclamationmark.triangle.fill",
                                isChecked: Binding(get: { c.wokeAt3am }, set: { c.wokeAt3am = $0 }),
                                isWarningFlag: true
                            )
                        }
                        .cardStyle(padding: 0)
                        .padding(.horizontal)
                    }

                    // 7-day sleep trend
                    let trend = viewModel.sevenDayTrend(logs: Array(allLogs))
                    if !trend.isEmpty {
                        SleepHistoryChart(dataPoints: trend)
                            .padding(.horizontal)
                    }

                    if let avg = viewModel.rollingAvgSleep(logs: recentLogs) {
                        HStack {
                            Text("7-day avg sleep quality:")
                            Spacer()
                            Text(String(format: "%.1f / 10", avg))
                                .monospacedDigit()
                                .foregroundStyle(avg >= 7 ? .brandGreen : avg >= 5 ? .brandOrange : .brandRed)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Sleep")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            todayLog = weekViewModel.findOrCreate(date: Date(), context: modelContext)
            ensureChecklist()
        }
    }
}
