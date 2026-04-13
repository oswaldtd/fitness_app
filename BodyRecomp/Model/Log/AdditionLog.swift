import Foundation
import SwiftData

@Model
final class AdditionLog {
    @Attribute(.unique) var id: UUID
    var additionID: UUID
    var additionName: String
    var isNonNegotiable: Bool
    var completed: Bool
    var loggedAt: Date?
    var dailyLog: DailyLog?

    init(
        id: UUID = UUID(),
        additionID: UUID,
        additionName: String,
        isNonNegotiable: Bool = false,
        completed: Bool = false
    ) {
        self.id = id
        self.additionID = additionID
        self.additionName = additionName
        self.isNonNegotiable = isNonNegotiable
        self.completed = completed
    }

    var isShake: Bool {
        additionName.lowercased().contains("shake") ||
        additionName.lowercased().contains("protein")
    }
}
