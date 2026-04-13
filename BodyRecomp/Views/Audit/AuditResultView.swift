import SwiftUI

struct AuditResultView: View {
    let audit: WeeklyAudit
    let activePlan: MealPlan?
    let onApplyDiff: () -> Void

    @State private var showingDiffReview = false

    var body: some View {
        guard let response = audit.parsedResponse else {
            return AnyView(
                Text("Unable to parse audit response.")
                    .foregroundStyle(.secondary)
                    .cardStyle()
            )
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Label("Audit — \(audit.weekStartDate.monthDayLabel)", systemImage: "brain.head.profile")
                        .font(.headline)
                    Spacer()
                    flagBadges(response.flags)
                }

                Divider()

                // Diagnosis
                VStack(alignment: .leading, spacing: 4) {
                    Text("DIAGNOSIS")
                        .sectionHeader()
                    Text(response.diagnosis)
                        .font(.subheadline)
                }

                // Recommendation
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECOMMENDATION")
                        .sectionHeader()
                    Text(response.recommendation)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.brandGreen)
                }

                // Coaching note
                if let note = response.coachingNote {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("COACHING NOTE")
                            .sectionHeader()
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }

                // Plan diff action
                if response.planDiff.hasChanges && !audit.userApprovedDiff {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PLAN CHANGES PROPOSED")
                            .sectionHeader()

                        if let cal = response.planDiff.targetCal {
                            HStack {
                                Text("Daily calorie target")
                                Spacer()
                                Text("→ \(cal) kcal")
                                    .foregroundStyle(.calorieColor)
                                    .monospacedDigit()
                            }
                            .font(.subheadline)
                        }
                        if let prot = response.planDiff.targetProteinG {
                            HStack {
                                Text("Protein target")
                                Spacer()
                                Text("→ \(Int(prot))g")
                                    .foregroundStyle(.proteinColor)
                                    .monospacedDigit()
                            }
                            .font(.subheadline)
                        }
                        if let timing = response.planDiff.shakeTiming {
                            HStack(alignment: .top) {
                                Text("Shake timing")
                                Spacer()
                                Text(timing)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                            .font(.subheadline)
                        }
                        if let note = response.planDiff.noteForUser {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            onApplyDiff()
                        } label: {
                            Text("Apply Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.brandGreen)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                } else if audit.userApprovedDiff {
                    Label("Plan changes applied", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.brandGreen)
                }
            }
            .cardStyle()
        )
    }

    @ViewBuilder
    private func flagBadges(_ flags: AuditResponse.AuditFlags) -> some View {
        HStack(spacing: 4) {
            if flags.stallDetected {
                flagBadge("Stall", color: .brandOrange)
            }
            if flags.sleepCortisolWarning {
                flagBadge("Sleep", color: .sleepColor)
            }
            if flags.adherenceConcern {
                flagBadge("Adherence", color: .brandRed)
            }
        }
    }

    private func flagBadge(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
