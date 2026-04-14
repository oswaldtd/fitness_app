import SwiftUI

struct DayStatusCell: View {
    let date: Date
    let log: DailyLog?
    let isToday: Bool

    private var isFuture: Bool { date > Date() && !Calendar.current.isDateInToday(date) }

    private var isRestDay: Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    private var completionColor: Color {
        guard let log else { return .clear }
        let score = log.completionScore
        if score >= 0.8 { return .brandGreen }
        if score >= 0.5 { return .brandOrange }
        return .brandRed.opacity(0.7)
    }

    var body: some View {
        VStack(spacing: 3) {
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

            // Pillar icons
            if let log, !isFuture {
                HStack(spacing: 2) {
                    pillarIcon("fork.knife", filled: !log.mealLogs.isEmpty)
                    if !isRestDay {
                        pillarIcon("dumbbell.fill", filled: log.workoutCompleted)
                    }
                    pillarIcon("moon.fill", filled: log.sleepQuality != nil)
                    pillarIcon("cup.and.saucer.fill", filled: log.shakeCompleted)
                }
            } else {
                // Placeholder to keep layout consistent
                HStack(spacing: 2) {
                    pillarIcon("fork.knife", filled: false).opacity(0)
                }
            }
        }
    }

    private func pillarIcon(_ name: String, filled: Bool) -> some View {
        Image(systemName: name)
            .font(.system(size: 6))
            .foregroundStyle(filled ? .brandGreen : .secondary.opacity(0.4))
    }
}
