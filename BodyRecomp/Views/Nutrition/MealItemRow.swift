import SwiftUI

struct MealItemRow: View {
    let item: MealItem

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                if !item.quantity.isEmpty {
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.calories)")
                    .font(.subheadline.monospacedDigit())
                Text("\(Int(item.proteinGrams))p")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.proteinColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 7)
    }
}
