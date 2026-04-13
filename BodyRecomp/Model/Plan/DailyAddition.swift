import Foundation
import SwiftData

@Model
final class DailyAddition {
    @Attribute(.unique) var id: UUID
    var name: String
    var calDelta: Int
    var proteinDeltaG: Double
    var isNonNegotiable: Bool
    var sortOrder: Int
    var timingNote: String
    var isArchived: Bool
    var plan: MealPlan?

    init(
        id: UUID = UUID(),
        name: String,
        calDelta: Int,
        proteinDeltaG: Double,
        isNonNegotiable: Bool = false,
        sortOrder: Int = 0,
        timingNote: String = ""
    ) {
        self.id = id
        self.name = name
        self.calDelta = calDelta
        self.proteinDeltaG = proteinDeltaG
        self.isNonNegotiable = isNonNegotiable
        self.sortOrder = sortOrder
        self.timingNote = timingNote
        self.isArchived = false
    }
}
