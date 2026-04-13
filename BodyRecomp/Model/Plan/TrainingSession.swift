import Foundation
import SwiftData

@Model
final class TrainingSession {
    @Attribute(.unique) var id: UUID
    var name: String
    var sessionType: SessionType
    /// Calendar weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
    var defaultWeekday: Int
    var sortOrder: Int
    var sessionDescription: String

    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise]

    init(
        id: UUID = UUID(),
        name: String,
        sessionType: SessionType,
        defaultWeekday: Int,
        sortOrder: Int = 0,
        sessionDescription: String = ""
    ) {
        self.id = id
        self.name = name
        self.sessionType = sessionType
        self.defaultWeekday = defaultWeekday
        self.sortOrder = sortOrder
        self.sessionDescription = sessionDescription
        self.exercises = []
    }

    var weekdayName: String {
        let names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let idx = defaultWeekday - 1
        guard idx >= 0, idx < names.count else { return "?" }
        return names[idx]
    }
}
