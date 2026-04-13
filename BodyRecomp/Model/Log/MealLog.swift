import Foundation
import SwiftData

@Model
final class MealLog {
    @Attribute(.unique) var id: UUID
    var slot: MealSlot
    var status: MealLogStatus
    var dailyLog: DailyLog?

    init(id: UUID = UUID(), slot: MealSlot, status: MealLogStatus = .onPlan) {
        self.id = id
        self.slot = slot
        self.status = status
    }
}
