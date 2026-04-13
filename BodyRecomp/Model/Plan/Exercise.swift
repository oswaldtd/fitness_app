import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetSets: Int
    var targetRepsLow: Int
    var targetRepsHigh: Int
    var repUnit: RepUnit
    var muscleGroup: MuscleGroup
    var notes: String
    var sortOrder: Int
    var session: TrainingSession?

    init(
        id: UUID = UUID(),
        name: String,
        targetSets: Int,
        targetRepsLow: Int,
        targetRepsHigh: Int? = nil,
        repUnit: RepUnit = .reps,
        muscleGroup: MuscleGroup,
        notes: String = "",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.targetSets = targetSets
        self.targetRepsLow = targetRepsLow
        self.targetRepsHigh = targetRepsHigh ?? targetRepsLow
        self.repUnit = repUnit
        self.muscleGroup = muscleGroup
        self.notes = notes
        self.sortOrder = sortOrder
    }

    var repsDisplay: String {
        let lo = targetRepsLow
        let hi = targetRepsHigh
        let suffix = repUnit == .seconds ? "s" : ""
        if lo == hi { return "\(lo)\(suffix)" }
        return "\(lo)–\(hi)\(suffix)"
    }

    var setsRepsLabel: String { "\(targetSets) × \(repsDisplay)" }
}
