import Foundation
import SwiftData

@Model
final class MealPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var isActive: Bool
    var targetCal: Int
    var targetProteinG: Double
    var targetFatG: Double
    var targetCarbsG: Double
    var deficitKcal: Int
    var weekNumber: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var meals: [Meal]

    @Relationship(deleteRule: .cascade)
    var dailyAdditions: [DailyAddition]

    init(
        id: UUID = UUID(),
        name: String,
        isActive: Bool = true,
        targetCal: Int = 2050,
        targetProteinG: Double = 175,
        targetFatG: Double = 65,
        targetCarbsG: Double = 195,
        deficitKcal: Int = 430,
        weekNumber: Int = 1
    ) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.targetCal = targetCal
        self.targetProteinG = targetProteinG
        self.targetFatG = targetFatG
        self.targetCarbsG = targetCarbsG
        self.deficitKcal = deficitKcal
        self.weekNumber = weekNumber
        self.createdAt = Date()
        self.meals = []
        self.dailyAdditions = []
    }
}
