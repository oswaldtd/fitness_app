import SwiftUI

/// Shown when user taps into a past audit to review what diff was applied
struct PlanDiffReviewView: View {
    let audit: WeeklyAudit

    var body: some View {
        List {
            if let response = audit.parsedResponse {
                Section("Audit") {
                    Text(response.diagnosis)
                        .font(.subheadline)
                }
                if response.planDiff.hasChanges {
                    Section("Changes Applied") {
                        if let cal = response.planDiff.targetCal {
                            LabeledContent("Calorie target", value: "\(cal) kcal")
                        }
                        if let prot = response.planDiff.targetProteinG {
                            LabeledContent("Protein target", value: "\(Int(prot))g")
                        }
                        if let timing = response.planDiff.shakeTiming {
                            LabeledContent("Shake timing", value: timing)
                        }
                    }
                }
            }

            if !audit.planHistoryEntries.isEmpty {
                Section("History Trail") {
                    ForEach(audit.planHistoryEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.mutationType)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("Before:")
                                Text(entry.previousValueJSON)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("After:")
                                Text(entry.newValueJSON)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.brandGreen)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Week of \(audit.weekStartDate.monthDayLabel)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
