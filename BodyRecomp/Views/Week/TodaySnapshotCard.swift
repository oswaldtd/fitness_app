import SwiftUI

struct TodaySnapshotCard: View {
    let log: DailyLog
    let plan: MealPlan

    private var mealsLogged: Int { log.mealLogs.count }
    private var totalMealSlots: Int {
        let variant = log.dayVariant ?? .broccoliDay
        return plan.meals.filter { $0.dayVariant == .both || $0.dayVariant == variant }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today")
                .font(.headline)
                .padding()

            Divider().padding(.horizontal)

            // Meals
            pillarRow(
                icon: "fork.knife",
                label: "Meals",
                value: "\(mealsLogged)/\(totalMealSlots) on plan",
                progress: totalMealSlots > 0 ? Double(mealsLogged) / Double(totalMealSlots) : 0,
                color: .brandGreen
            )

            Divider().padding(.horizontal)

            // Protein
            let protein = log.proteinGrams ?? 0
            let proteinTarget = plan.targetProteinG
            pillarRow(
                icon: "p.circle.fill",
                label: "Protein",
                value: "\(Int(protein))g / \(Int(proteinTarget))g",
                progress: proteinTarget > 0 ? protein / proteinTarget : 0,
                color: .proteinColor
            )

            Divider().padding(.horizontal)

            // Calories
            let calories = log.caloriesConsumed ?? 0
            let calTarget = plan.targetCal
            pillarRow(
                icon: "flame.fill",
                label: "Calories",
                value: "\(calories) / \(calTarget) kcal",
                progress: calTarget > 0 ? Double(calories) / Double(calTarget) : 0,
                color: .calorieColor
            )

            Divider().padding(.horizontal)

            // Workout
            if log.isRestDay {
                statusRow(icon: "figure.cooldown", label: "Workout", status: "Rest day", color: .secondary)
            } else {
                statusRow(
                    icon: "dumbbell.fill",
                    label: "Workout",
                    status: log.workoutCompleted ? "Done" : "Not yet",
                    color: log.workoutCompleted ? .brandGreen : .secondary
                )
            }

            Divider().padding(.horizontal)

            // Sleep
            if let sleep = log.sleepQuality {
                statusRow(icon: "moon.fill", label: "Sleep", status: "\(sleep)/10", color: .sleepColor)
            } else {
                statusRow(icon: "moon.fill", label: "Sleep", status: "Rate in Sleep tab", color: .secondary)
            }

            Divider().padding(.horizontal)

            // Shake
            let shakeDone = log.additionLogs.first(where: { $0.isShake })?.completed == true
            statusRow(
                icon: "cup.and.saucer.fill",
                label: "Shake",
                status: shakeDone ? "Done" : "Not yet",
                color: shakeDone ? .brandGreen : .brandOrange
            )
        }
        .cardStyle(padding: 0)
    }

    private func pillarRow(icon: String, label: String, value: String, progress: Double, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 22)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(progress >= 0.85 ? color : .secondary)

            // Mini progress
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 5)
                Capsule()
                    .fill(color)
                    .frame(width: 40 * min(progress, 1.0), height: 5)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func statusRow(icon: String, label: String, status: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 22)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(status)
                .font(.subheadline)
                .foregroundStyle(color)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
