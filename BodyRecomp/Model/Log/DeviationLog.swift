import Foundation
import SwiftData

@Model
final class DeviationLog {
    @Attribute(.unique) var id: UUID
    var deviationType: DeviationType
    var slot: MealSlot?
    var descriptionText: String
    var calories: Int?
    var proteinGrams: Double?
    var fatGrams: Double?
    var carbsGrams: Double?
    var loggedAt: Date
    var dailyLog: DailyLog?

    init(
        id: UUID = UUID(),
        deviationType: DeviationType,
        slot: MealSlot? = nil,
        descriptionText: String,
        calories: Int? = nil,
        proteinGrams: Double? = nil,
        fatGrams: Double? = nil,
        carbsGrams: Double? = nil
    ) {
        self.id = id
        self.deviationType = deviationType
        self.slot = slot
        self.descriptionText = descriptionText
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.carbsGrams = carbsGrams
        self.loggedAt = Date()
    }
}
