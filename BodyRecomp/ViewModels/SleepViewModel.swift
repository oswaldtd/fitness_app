import Foundation
import SwiftData
import Observation

@Observable
final class SleepViewModel {

    // MARK: - Cortisol warning logic

    /// Shows warning if sleep ≤ 5 for 3+ consecutive days OR 3am waking occurred
    func shouldShowCortisolWarning(recentLogs: [DailyLog]) -> Bool {
        // Check for 3am waking in last 3 days
        let recentThree = Array(recentLogs.sorted { $0.date > $1.date }.prefix(3))
        if recentThree.contains(where: { $0.sleepChecklist?.wokeAt3am == true }) {
            return true
        }

        // Check for sleep ≤ 5 for 3+ consecutive days
        let sorted = recentLogs.sorted { $0.date > $1.date }
        var consecutiveLow = 0
        for log in sorted {
            if let score = log.sleepQuality, score <= 5 {
                consecutiveLow += 1
                if consecutiveLow >= 3 { return true }
            } else {
                break
            }
        }
        return false
    }

    func cortisolWarningMessage(recentLogs: [DailyLog]) -> String {
        let hasRecentWaking = recentLogs.sorted { $0.date > $1.date }.prefix(3)
            .contains(where: { $0.sleepChecklist?.wokeAt3am == true })

        if hasRecentWaking {
            return "3am waking detected. If this pattern is new or worsening, mention it to your prescribing doctor. Prioritize sleep tonight."
        }
        return "Sleep quality has been below 5 for 3+ days. Cortisol may be elevated — this is the primary bottleneck right now, not your calories."
    }

    // MARK: - Checklist helpers

    func getOrCreateChecklist(for dailyLog: DailyLog, context: ModelContext) -> SleepChecklist {
        if let existing = dailyLog.sleepChecklist { return existing }
        let checklist = SleepChecklist()
        checklist.dailyLog = dailyLog
        context.insert(checklist)
        return checklist
    }

    // MARK: - 7-day trend data

    struct SleepDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let score: Double
    }

    func sevenDayTrend(logs: [DailyLog]) -> [SleepDataPoint] {
        let week = Date().weekDays
        return week.compactMap { day -> SleepDataPoint? in
            guard let log = logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }),
                  let score = log.sleepQuality else { return nil }
            return SleepDataPoint(date: day, score: Double(score))
        }
    }

    func rollingAvgSleep(logs: [DailyLog]) -> Double? {
        let values = logs.compactMap { $0.sleepQuality.map { Double($0) } }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }
}
