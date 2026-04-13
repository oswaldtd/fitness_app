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

    var isComplete: Bool {
        proteinGrams != nil &&
        caloriesConsumed != nil &&
        sleepQuality != nil &&
        energyLevel != nil
    }

    var completionScore: Double {
        var count = 0.0
        if proteinGrams != nil { count += 1 }
        if caloriesConsumed != nil { count += 1 }
        if sleepQuality != nil { count += 1 }
        if energyLevel != nil { count += 1 }
        if workoutCompleted { count += 1 }
        let shakeLogged = additionLogs.first(where: { $0.isShake })?.completed == true
        if shakeLogged { count += 1 }
        return count / 6.0
    }

    var shakeCompleted: Bool {
        get { additionLogs.first(where: { $0.isShake })?.completed ?? false }
    }
}
