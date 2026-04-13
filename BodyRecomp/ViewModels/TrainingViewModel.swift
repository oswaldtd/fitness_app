import Foundation
import SwiftData
import Observation

@Observable
final class TrainingViewModel {
    var selectedDate: Date = Date()
    var activeSessionLog: SessionLog?
    var showingPastSessions = false

    // MARK: - Today's session

    func todaySession(from sessions: [TrainingSession]) -> TrainingSession? {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        return sessions.first(where: { $0.defaultWeekday == weekday })
    }

    var isRestDay: Bool {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        return weekday == 1 || weekday == 7  // Sun or Sat
    }

    var isOptionalWalkDay: Bool {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        return weekday == 7  // Saturday
    }

    // MARK: - Session log management

    @MainActor
    func startSession(for session: TrainingSession, dailyLog: DailyLog, context: ModelContext) -> SessionLog {
        let log = SessionLog(
            sessionID: session.id,
            sessionName: session.name,
            sessionType: session.sessionType
        )
        log.dailyLog = dailyLog
        context.insert(log)
        activeSessionLog = log
        return log
    }

    @MainActor
    func addSet(
        to sessionLog: SessionLog,
        exercise: Exercise,
        reps: Int,
        weight: Double?,
        context: ModelContext
    ) {
        let setNumber = sessionLog.setLogs.filter { $0.exerciseID == exercise.id }.count + 1
        let setLog = SetLog(
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            muscleGroup: exercise.muscleGroup,
            setNumber: setNumber,
            repsCompleted: reps,
            weightLbs: weight
        )
        setLog.sessionLog = sessionLog
        context.insert(setLog)
    }

    @MainActor
    func completeSession(_ sessionLog: SessionLog, effort: Int, notes: String, dailyLog: DailyLog) {
        sessionLog.perceivedEffort = effort
        sessionLog.notes = notes
        sessionLog.completedAt = Date()
        dailyLog.workoutCompleted = true
        activeSessionLog = nil
    }

    // MARK: - Volume analytics

    func weeklyVolumeByMuscle(sessionLogs: [SessionLog]) -> [MuscleGroup: Int] {
        var result: [MuscleGroup: Int] = [:]
        for session in sessionLogs {
            for setLog in session.setLogs {
                result[setLog.muscleGroup, default: 0] += 1
            }
        }
        return result
    }

    func setsLogged(for exercise: Exercise, in sessionLog: SessionLog) -> [SetLog] {
        sessionLog.setLogs
            .filter { $0.exerciseID == exercise.id }
            .sorted { $0.setNumber < $1.setNumber }
    }
}
