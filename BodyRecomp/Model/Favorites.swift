import Foundation
import SwiftData

@Model
final class Favorites {
    @Attribute(.unique) var id: UUID
    var name: String
    var calories: Int
    var proteinGrams: Double
    var fatGrams: Double
    var carbsGrams: Double
    var useCount: Int
    var lastUsedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        proteinGrams: Double,
        fatGrams: Double = 0,
        carbsGrams: Double = 0
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.fatGrams = fatGrams
        self.carbsGrams = carbsGrams
        self.useCount = 1
        self.lastUsedAt = Date()
    }
}
