import Foundation
import SwiftData

/// Applies an approved AuditResponse.PlanDiffPayload to the active MealPlan.
/// All mutations are append-only: the live plan is updated in-place,
/// and every change is recorded in PlanHistory.
enum PlanDiffApplicator {

    static func apply(
        diff: AuditResponse.PlanDiffPayload,
        to plan: MealPlan,
        audit: WeeklyAudit,
        context: ModelContext
    ) {
        if let newCal = diff.targetCal {
            let history = PlanHistory(
                mutationType: "targetCalChanged",
                entityType: "MealPlan",
                entityID: plan.id,
                previousValueJSON: "{\"target_cal\":\(plan.targetCal)}",
                newValueJSON: "{\"target_cal\":\(newCal)}"
            )
            plan.targetCal = newCal
            plan.deficitKcal = 2480 - newCal   // recalculate vs TDEE
            audit.planHistoryEntries.append(history)
            context.insert(history)
        }

        if let newProtein = diff.targetProteinG {
            let history = PlanHistory(
                mutationType: "targetProteinChanged",
                entityType: "MealPlan",
                entityID: plan.id,
                previousValueJSON: "{\"target_protein_g\":\(plan.targetProteinG)}",
                newValueJSON: "{\"target_protein_g\":\(newProtein)}"
            )
            plan.targetProteinG = newProtein
            audit.planHistoryEntries.append(history)
            context.insert(history)
        }

        if let timingNote = diff.shakeTiming {
            // Find protein shake addition and update its timing note
            if let shake = plan.dailyAdditions.first(where: { $0.isNonNegotiable && !$0.isArchived }) {
                let history = PlanHistory(
                    mutationType: "shakeTimingChanged",
                    entityType: "DailyAddition",
                    entityID: shake.id,
                    previousValueJSON: "{\"timing_note\":\"\(shake.timingNote)\"}",
                    newValueJSON: "{\"timing_note\":\"\(timingNote)\"}"
                )
                shake.timingNote = timingNote
                audit.planHistoryEntries.append(history)
                context.insert(history)
            }
        }

        audit.userApprovedDiff = true
        audit.completedAt = Date()
        plan.weekNumber += 1
    }
}

extension DailyAddition {
    var isShakeAddition: Bool {
        name.lowercased().contains("shake") || name.lowercased().contains("protein")
    }
}
