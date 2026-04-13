import Foundation
import SwiftData

@Model
final class PlanHistory {
    @Attribute(.unique) var id: UUID
    var mutationType: String
    var entityType: String
    var entityID: UUID
    var previousValueJSON: String
    var newValueJSON: String
    var appliedAt: Date
    var audit: WeeklyAudit?

    init(
        id: UUID = UUID(),
        mutationType: String,
        entityType: String,
        entityID: UUID,
        previousValueJSON: String,
        newValueJSON: String
    ) {
        self.id = id
        self.mutationType = mutationType
        self.entityType = entityType
        self.entityID = entityID
        self.previousValueJSON = previousValueJSON
        self.newValueJSON = newValueJSON
        self.appliedAt = Date()
    }
}
