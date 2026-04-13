import Foundation
import SwiftData
import Observation

@Observable
final class WeekViewModel {
    var selectedDate: Date = Date()

    // MARK: - Week data

    var weekDays: [Date] { selectedDate.weekDays }

    var weekRangeLabel: String {
        let days = weekDays
        guard let first = days.first, let last = days.last else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first)) – \(f.string(from: last))"
    }

    // MARK: - Derived stats (computed from passed-in logs)

    func avgProtein(logs: [DailyLog]) -> Double? {
        let values = logs.compactMap { $0.proteinGrams }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    func avgSleep(logs: [DailyLog]) -> Double? {
        let values = logs.compactMap { $0.sleepQuality.map { Double($0) } }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    func avgEnergy(logs: [DailyLog]) -> Double? {
        let values = logs.compactMap { $0.energyLevel.map { Double($0) } }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    func sessionsCompleted(logs: [DailyLog]) -> Int {
        logs.filter { $0.workoutCompleted }.count
    }

    func shakeCompletionRate(logs: [DailyLog]) -> Double {
        let completed = logs.filter { $0.shakeCompleted }.count
        guard !logs.isEmpty else { return 0 }
        return Double(completed) / Double(logs.count)
    }

    func proteinAdherence(logs: [DailyLog], target: Double) -> Double {
        let values = logs.compactMap { $0.proteinGrams }
        guard !values.isEmpty else { return 0 }
        let achieved = values.filter { $0 >= target * 0.85 }.count
        return Double(achieved) / Double(values.count)
    }

    // MARK: - Day log lookup

    func log(for date: Date, from logs: [DailyLog]) -> DailyLog? {
        logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }

    // MARK: - Find or create DailyLog for a date

    @MainActor
    func findOrCreate(date: Date, context: ModelContext) -> DailyLog {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailyLog>()
        let all = (try? context.fetch(descriptor)) ?? []
        if let existing = all.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }) {
            return existing
        }
        let log = DailyLog(date: startOfDay)
        context.insert(log)

        // Auto-create addition logs from active plan
        let planDescriptor = FetchDescriptor<MealPlan>()
        if let plan = (try? context.fetch(planDescriptor))?.first(where: { $0.isActive }) {
            for addition in plan.dailyAdditions where !addition.isArchived {
                let addLog = AdditionLog(
                    additionID: addition.id,
                    additionName: addition.name,
                    isNonNegotiable: addition.isNonNegotiable
                )
                addLog.dailyLog = log
                context.insert(addLog)
            }
        }

        return log
    }
}
