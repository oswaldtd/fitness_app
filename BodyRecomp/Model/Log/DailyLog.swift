import Foundation
import SwiftData

@Model
final class DailyLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var dayVariant: DayVariant?
    var proteinGrams: Double?
    var caloriesConsumed: Int?
    var sleepQuality: Int?
    var energyLevel: Int?
    var workoutCompleted: Bool
    var notes: String

    @Relationship(deleteRule: .cascade)
    var sleepChecklist: SleepChecklist?

    @Relationship(deleteRule: .cascade)
    var mealLogs: [MealLog]

    @Relationship(deleteRule: .cascade)
    var additionLogs: [AdditionLog]

    @Relationship(deleteRule: .cascade)
    var deviationLogs: [DeviationLog]

    @Relationship(deleteRule: .cascade)
    var sessionLog: SessionLog?

    init(id: UUID = UUID(), date: Date) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.workoutCompleted = false
        self.notes = ""
        self.mealLogs = []
        self.additionLogs = []
        self.deviationLogs = []
    }

    var isRestDay: Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // Sunday or Saturday
    }

    var isComplete: Bool {
        let hasNutrition = (proteinGrams ?? 0) > 0
        let hasSleep = sleepQuality != nil
        let hasEnergy = energyLevel != nil
        return hasNutrition && hasSleep && hasEnergy
    }

    var completionScore: Double {
        var score = 0.0
        var total = 4.0 // nutrition, protein, sleep, shake

        if !mealLogs.isEmpty { score += 1 }
        if let p = proteinGrams, p > 0 { score += 1 }
        if sleepQuality != nil { score += 1 }
        if additionLogs.first(where: { $0.isShake })?.completed == true { score += 1 }

        if !isRestDay {
            total += 1
            if workoutCompleted { score += 1 }
        }

        return score / total
    }

    var shakeCompleted: Bool {
        get { additionLogs.first(where: { $0.isShake })?.completed ?? false }
    }
}
