import Foundation
import SwiftData

@Model
final class WeeklyAudit {
    @Attribute(.unique) var id: UUID
    var weekStartDate: Date
    var triggeredAt: Date
    var completedAt: Date?
    var contextPackageJSON: String
    var rawResponseJSON: String?
    var status: AuditStatus
    var userApprovedDiff: Bool

    @Relationship(deleteRule: .cascade)
    var planHistoryEntries: [PlanHistory]

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        contextPackageJSON: String = ""
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.triggeredAt = Date()
        self.contextPackageJSON = contextPackageJSON
        self.status = .pending
        self.userApprovedDiff = false
        self.planHistoryEntries = []
    }

    var parsedResponse: AuditResponse? {
        guard let json = rawResponseJSON,
              let data = json.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(AuditResponse.self, from: data)
    }
}
