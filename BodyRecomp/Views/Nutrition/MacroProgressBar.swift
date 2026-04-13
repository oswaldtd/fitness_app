import SwiftUI

struct MacroProgressBar: View {
    let log: DailyLog
    let variant: DayVariant
    let plan: MealPlan
    let viewModel: NutritionViewModel

    private var calorieActual: Int { viewModel.actualCalories(log: log, variant: variant, plan: plan) }
    private var proteinActual: Double { viewModel.actualProtein(log: log, variant: variant, plan: plan) }
    private var calProgress: Double { viewModel.calorieProgress(log: log, variant: variant, plan: plan) }
    private var proteinProgress: Double { viewModel.proteinProgress(log: log, variant: variant, plan: plan) }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 16) {
                macroRing(
                    progress: calProgress,
                    actual: "\(calorieActual)",
                    target: "\(plan.targetCal)",
                    unit: "kcal",
                    color: .calorieColor
                )
                macroRing(
                    progress: proteinProgress,
                    actual: "\(Int(proteinActual))",
                    target: "\(Int(plan.targetProteinG))",
                    unit: "protein",
                    color: .proteinColor
                )

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    macroChip(label: "Fat", value: "\(Int(plan.targetFatG))g target")
                    macroChip(label: "Carbs", value: "\(Int(plan.targetCarbsG))g target")
                }
            }
        }
        .cardStyle()
    }

    private func macroRing(
        progress: Double,
        actual: String,
        target: String,
        unit: String,
        color: Color
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RingProgress(value: progress, color: color, lineWidth: 6, size: 60)
                VStack(spacing: 0) {
                    Text(actual)
                        .font(.callout.bold().monospacedDigit())
                    Text("/ \(target)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func macroChip(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
