import Foundation
import SwiftData

/// Assembles the JSON context package sent to Claude for the weekly audit.
enum AuditContextBuilder {

    struct CheckInAnswers {
        var waistMeasurementIn: Double?
        var adherenceGutCheck: AdherenceGutCheck = .honest
    }

    static func build(
        weekStartDate: Date,
        dailyLogs: [DailyLog],
        activePlan: MealPlan?,
        previousAudit: WeeklyAudit?,
        checkInAnswers: CheckInAnswers
    ) -> String {
        var package: [String: Any] = [:]

        // User profile (static for this user)
        package["user_profile"] = [
            "age": 35,
            "weight_lbs": 190,
            "height_in": 70,
            "estimated_bf_pct": 29,
            "lean_mass_lbs": 135,
            "tdee_kcal": 2480,
            "target_bf_pct": "18-20%"
        ]

        // Current plan
        if let plan = activePlan {
            package["current_plan"] = [
                "target_cal": plan.targetCal,
                "target_protein_g": plan.targetProteinG,
                "target_fat_g": plan.targetFatG,
                "target_carbs_g": plan.targetCarbsG,
                "deficit_kcal": plan.deficitKcal,
                "week_number": plan.weekNumber,
                "total_weeks": 4
            ]
        }

        // Week logs
        let logsInWindow = dailyLogs.filter { log in
            let dayOfWeek = weekStartDate.weekDays
            return dayOfWeek.contains(where: { $0.isSameDay(log.date) })
        }.sorted { $0.date < $1.date }

        package["week_logs"] = logsInWindow.map { log -> [String: Any] in
            var entry: [String: Any] = [
                "date": log.date.isoDateString,
                "day_variant": log.dayVariant?.rawValue ?? "not_set",
                "total_cal": log.caloriesConsumed as Any,
                "total_protein_g": log.proteinGrams as Any,
                "sleep_score": log.sleepQuality as Any,
                "energy_score": log.energyLevel as Any,
                "workout_completed": log.workoutCompleted,
                "shake_completed": log.shakeCompleted,
                "deviation_count": log.deviationLogs.count,
                "deviation_modes": log.deviationLogs.map { $0.deviationType.rawValue }
            ]

            if let checklist = log.sleepChecklist {
                entry["sleep_checklist"] = [
                    "magnesium_taken": checklist.magnesiumTaken,
                    "pre_bed_snack": checklist.preBedSnackEaten,
                    "no_training_last_3hrs": checklist.noTrainingLast3hrs,
                    "consistent_sleep_time": checklist.consistentSleepTime,
                    "morning_light": checklist.morningLightWithin30min,
                    "woke_at_3am": checklist.wokeAt3am
                ]
            }

            return entry
        }

        // Previous audit summary
        if let prev = previousAudit, let response = prev.parsedResponse {
            package["previous_audit"] = [
                "week_start": prev.weekStartDate.isoDateString,
                "diagnosis": response.diagnosis,
                "recommendation": response.recommendation,
                "plan_diff_applied": prev.userApprovedDiff
            ]
        } else {
            package["previous_audit"] = NSNull()
        }

        // Weekly check-in answers
        var answers: [String: Any] = [
            "avg_sleep_rating": avgSleep(logs: logsInWindow),
            "avg_energy_rating": avgEnergy(logs: logsInWindow),
            "adherence_gut_check": checkInAnswers.adherenceGutCheck.rawValue
        ]
        if let waist = checkInAnswers.waistMeasurementIn {
            answers["waist_measurement_in"] = waist
        } else {
            answers["waist_measurement_in"] = NSNull()
        }
        package["check_in_answers"] = answers

        // Serialize to pretty JSON for readability in stored record
        guard let data = try? JSONSerialization.data(withJSONObject: package, options: [.prettyPrinted, .sortedKeys]),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    // MARK: - Helpers

    private static func avgSleep(logs: [DailyLog]) -> Double {
        let values = logs.compactMap { $0.sleepQuality.map { Double($0) } }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func avgEnergy(logs: [DailyLog]) -> Double {
        let values = logs.compactMap { $0.energyLevel.map { Double($0) } }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
}
