import Foundation
import SwiftData

@Model
final class SessionLog {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var sessionName: String
    var sessionType: SessionType
    var perceivedEffort: Int?
    var notes: String
    var completedAt: Date?
    var dailyLog: DailyLog?

    @Relationship(deleteRule: .cascade)
    var setLogs: [SetLog]

    init(
        id: UUID = UUID(),
        sessionID: UUID,
        sessionName: String,
        sessionType: SessionType
    ) {
        self.id = id
        self.sessionID = sessionID
        self.sessionName = sessionName
        self.sessionType = sessionType
        self.notes = ""
        self.setLogs = []
    }

    var totalSets: Int { setLogs.count }

    var volumeByMuscle: [MuscleGroup: Int] {
        var result: [MuscleGroup: Int] = [:]
        for log in setLogs {
            result[log.muscleGroup, default: 0] += 1
        }
        return result
    }
}
