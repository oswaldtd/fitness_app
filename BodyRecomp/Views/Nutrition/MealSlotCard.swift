import SwiftUI

struct MealSlotCard: View {
    let meal: Meal
    let slot: MealSlot
    let log: DailyLog?
    let plan: MealPlan
    let onDeviation: () -> Void

    @State private var isExpanded = true

    private var slotLog: MealLog? {
        log?.mealLogs.first(where: { $0.slot == slot })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(slot.emoji)
                    Text(slot.displayName)
                        .font(.headline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(meal.totalCalories) cal")
                            .font(.subheadline.monospacedDigit())
                        Text("\(Int(meal.totalProtein))g protein")
                            .font(.caption)
                            .foregroundStyle(.proteinColor)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
            }
            .buttonStyle(.plain)
            .padding()

            if isExpanded {
                Divider()
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    ForEach(meal.items.sorted { $0.sortOrder < $1.sortOrder }) { item in
                        MealItemRow(item: item)
                    }
                }

                // Deviations for this slot
                if let log {
                    let deviations = log.deviationLogs.filter { $0.slot == slot }
                    if !deviations.isEmpty {
                        Divider().padding(.horizontal)
                        ForEach(deviations) { dev in
                            DeviationRow(deviation: dev)
                        }
                    }
                }

                Divider()
                    .padding(.horizontal)

                Button {
                    onDeviation()
                } label: {
                    Label("Add deviation", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(.brandGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .cardStyle(padding: 0)
    }
}

struct DeviationRow: View {
    let deviation: DeviationLog

    var body: some View {
        HStack {
            Image(systemName: deviation.deviationType.icon)
                .foregroundStyle(.brandOrange)
                .frame(width: 20)
            Text(deviation.descriptionText)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let cal = deviation.calories {
                    Text("+\(cal) cal")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                if let prot = deviation.proteinGrams, prot > 0 {
                    Text("+\(Int(prot))g p")
                        .font(.caption)
                        .foregroundStyle(.proteinColor)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
