import SwiftUI

struct DayStatusCell: View {
    let date: Date
    let log: DailyLog?
    let isToday: Bool

    private var isFuture: Bool { date > Date() && !Calendar.current.isDateInToday(date) }

    private var completionColor: Color {
        guard let log else { return .clear }
        let score = log.completionScore
        if score >= 0.8 { return .brandGreen }
        if score >= 0.5 { return .brandOrange }
        return .brandRed.opacity(0.7)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(date.shortDayLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isToday ? .brandGreen : .secondary)

            ZStack {
                Circle()
                    .fill(isToday ? Color.brandGreen.opacity(0.15) : Color(.tertiarySystemBackground))
                    .frame(width: 36, height: 36)

                if let log, !isFuture {
                    Circle()
                        .trim(from: 0, to: log.completionScore)
                        .stroke(completionColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 33, height: 33)
                }

                Text(date.dayNumber)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(isFuture ? .secondary.opacity(0.5) : (isToday ? .brandGreen : .primary))
            }

            // Protein dot indicator
            if let log, let protein = log.proteinGrams {
                Circle()
                    .fill(protein >= 160 ? Color.brandGreen : Color.brandOrange)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
    }
}
