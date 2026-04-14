import SwiftUI

struct GapCloserSection: View {
    let log: DailyLog
    let plan: MealPlan
    var onToggled: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Gap-Closers")
                    .font(.headline)
                Spacer()
                Text("+\(totalCompletedCals) cal · +\(Int(totalCompletedProtein))g p")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider().padding(.horizontal)

            ForEach(plan.dailyAdditions.filter { !$0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }) { addition in
                additionRow(addition)
                if addition !== plan.dailyAdditions.filter({ !$0.isArchived }).sorted(by: { $0.sortOrder < $1.sortOrder }).last {
                    Divider().padding(.horizontal)
                }
            }
        }
        .cardStyle(padding: 0)
    }

    private func additionRow(_ addition: DailyAddition) -> some View {
        let addLog = log.additionLogs.first(where: { $0.additionID == addition.id })
        let isCompleted = addLog?.completed ?? false

        return HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isCompleted ? .brandGreen : (addition.isNonNegotiable ? .brandOrange : .secondary))
                .onTapGesture {
                    toggle(addition: addition, log: log)
                }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(addition.name)
                        .font(.subheadline)
                        .lineLimit(2)
                    if addition.isNonNegotiable {
                        Text("required")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                if !addition.timingNote.isEmpty {
                    Text(addition.timingNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(addition.calDelta)")
                    .font(.caption.monospacedDigit())
                Text("+\(Int(addition.proteinDeltaG))g")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.proteinColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            toggle(addition: addition, log: log)
        }
    }

    private func toggle(addition: DailyAddition, log: DailyLog) {
        if let existing = log.additionLogs.first(where: { $0.additionID == addition.id }) {
            existing.completed.toggle()
            existing.loggedAt = existing.completed ? Date() : nil
            onToggled()
        }
    }

    private var totalCompletedCals: Int {
        log.additionLogs
            .filter { $0.completed }
            .compactMap { addLog in
                plan.dailyAdditions.first(where: { $0.id == addLog.additionID })?.calDelta
            }
            .reduce(0, +)
    }

    private var totalCompletedProtein: Double {
        log.additionLogs
            .filter { $0.completed }
            .compactMap { addLog in
                plan.dailyAdditions.first(where: { $0.id == addLog.additionID })?.proteinDeltaG
            }
            .reduce(0, +)
    }
}
