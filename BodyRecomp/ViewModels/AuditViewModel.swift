import Foundation
import SwiftData
import Observation

@Observable
final class AuditViewModel {
    var isRunning = false
    var errorMessage: String?
    var currentAudit: WeeklyAudit?

    // Check-in answers collected before running audit
    var waistMeasurementIn: String = ""
    var adherenceGutCheck: AdherenceGutCheck = .honest

    // MARK: - Audit trigger availability

    var isAuditAvailable: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 || weekday == 2  // Sunday=1 or Monday=2 (grace period)
    }

    var auditButtonLabel: String {
        if isRunning { return "Running audit…" }
        let weekday = Calendar.current.component(.weekday, from: Date())
        if weekday == 2 { return "Run Last Week's Audit" }
        return "Run Weekly Audit"
    }

    var weekStartForAudit: Date {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // On Monday grace period, show previous week
        if weekday == 2 {
            return Calendar.current.date(byAdding: .day, value: -7, to: Date())!.mondayOfWeek
        }
        return Date().mondayOfWeek
    }

    // MARK: - Run audit

    @MainActor
    func runAudit(
        dailyLogs: [DailyLog],
        activePlan: MealPlan?,
        previousAudit: WeeklyAudit?,
        context: ModelContext
    ) async {
        guard !isRunning else { return }
        isRunning = true
        errorMessage = nil

        let checkInAnswers = AuditContextBuilder.CheckInAnswers(
            waistMeasurementIn: Double(waistMeasurementIn),
            adherenceGutCheck: adherenceGutCheck
        )

        let contextPackage = AuditContextBuilder.build(
            weekStartDate: weekStartForAudit,
            dailyLogs: dailyLogs,
            activePlan: activePlan,
            previousAudit: previousAudit,
            checkInAnswers: checkInAnswers
        )

        let audit = WeeklyAudit(weekStartDate: weekStartForAudit, contextPackageJSON: contextPackage)
        context.insert(audit)
        audit.status = .inProgress
        currentAudit = audit

        do {
            let response = try await ClaudeService.runAudit(contextPackage: contextPackage)
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            if let data = try? encoder.encode(response),
               let json = String(data: data, encoding: .utf8) {
                audit.rawResponseJSON = json
            }
            audit.status = .complete
            audit.completedAt = Date()
        } catch {
            audit.status = .failed
            errorMessage = error.localizedDescription
        }

        isRunning = false
    }

    // MARK: - Apply plan diff

    @MainActor
    func applyDiff(from audit: WeeklyAudit, to plan: MealPlan, context: ModelContext) {
        guard let response = audit.parsedResponse,
              response.planDiff.hasChanges else { return }
        PlanDiffApplicator.apply(diff: response.planDiff, to: plan, audit: audit, context: context)
    }
}
