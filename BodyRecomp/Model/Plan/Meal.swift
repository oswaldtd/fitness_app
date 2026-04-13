import Foundation
import SwiftData

@Model
final class Meal {
    @Attribute(.unique) var id: UUID
    var slot: MealSlot
    var dayVariant: DayVariant
    var sortOrder: Int
    var plan: MealPlan?

    @Relationship(deleteRule: .cascade)
    var items: [MealItem]

    init(id: UUID = UUID(), slot: MealSlot, dayVariant: DayVariant, sortOrder: Int = 0) {
        self.id = id
        self.slot = slot
        self.dayVariant = dayVariant
        self.sortOrder = sortOrder
        self.items = []
    }

    var totalCalories: Int { items.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { items.reduce(0) { $0 + $1.proteinGrams } }
    var totalFat: Double { items.reduce(0) { $0 + $1.fatGrams } }
    var totalCarbs: Double { items.reduce(0) { $0 + $1.carbsGrams } }
}
