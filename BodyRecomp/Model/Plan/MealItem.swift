import Foundation
import SwiftData

@Model
final class MealItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: String
    var calories: Int
    var proteinGrams: Double
    var fatGrams: Double
    var carbsGrams: Double
    var sortOrder: Int
    var meal: Meal?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: String = "",
        calories: Int,
        proteinGrams: Double,
        fatGrams: Double,
        carbsGrams: Double,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.carbsGrams = carbsGrams
        self.sortOrder = sortOrder
    }

    var macroSummary: String {
        "\(calories) cal · \(Int(proteinGrams))p · \(Int(fatGrams))f · \(Int(carbsGrams))c"
    }
}
