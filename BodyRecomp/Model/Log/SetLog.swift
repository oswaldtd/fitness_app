import Foundation
import SwiftData

@Model
final class SetLog {
    @Attribute(.unique) var id: UUID
    /// Not a SwiftData relationship — denormalized so history survives plan mutations
    var exerciseID: UUID
    var exerciseName: String
    var muscleGroup: MuscleGroup
    var setNumber: Int
    var repsCompleted: Int
    var weightLbs: Double?
    var sessionLog: SessionLog?

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        exerciseName: String,
        muscleGroup: MuscleGroup,
        setNumber: Int,
        repsCompleted: Int,
        weightLbs: Double? = nil
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.setNumber = setNumber
        self.repsCompleted = repsCompleted
        self.weightLbs = weightLbs
    }
}
