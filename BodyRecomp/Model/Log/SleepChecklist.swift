import Foundation
import SwiftData

@Model
final class SleepChecklist {
    @Attribute(.unique) var id: UUID
    var magnesiumTaken: Bool
    var preBedSnackEaten: Bool
    var noTrainingLast3hrs: Bool
    var consistentSleepTime: Bool
    var morningLightWithin30min: Bool
    var wokeAt3am: Bool
    var dailyLog: DailyLog?

    init(id: UUID = UUID()) {
        self.id = id
        self.magnesiumTaken = false
        self.preBedSnackEaten = false
        self.noTrainingLast3hrs = false
        self.consistentSleepTime = false
        self.morningLightWithin30min = false
        self.wokeAt3am = false
    }

    var completedCount: Int {
        [magnesiumTaken, preBedSnackEaten, noTrainingLast3hrs, consistentSleepTime, morningLightWithin30min]
            .filter { $0 }.count
    }
}
