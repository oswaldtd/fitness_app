import SwiftUI

struct WeekSummaryBanner: View {
    let logs: [DailyLog]
    let targetProtein: Double
    var targetCalories: Int = 2050
    let viewModel: WeekViewModel

    private var daysLogged: Int { logs.filter { $0.isComplete }.count }
    private var totalDays: Int { 7 }

    var body: some View {
        HStack(spacing: 0) {
            // Days complete ring
            VStack(spacing: 4) {
                ZStack {
                    RingProgress(
                        value: Double(daysLogged) / Double(totalDays),
                        color: .brandGreen,
                        lineWidth: 5,
                        size: 56
                    )
                    VStack(spacing: 0) {
                        Text("\(daysLogged)")
                            .font(.title3.bold().monospacedDigit())
                        Text("/ \(totalDays)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Text("Days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 50)

            // Avg protein
            VStack(spacing: 4) {
                if let avg = viewModel.avgProtein(logs: logs) {
                    Text("\(Int(avg))g")
                        .font(.title3.bold().monospacedDigit())
                        .foregroundStyle(avg >= targetProtein * 0.85 ? .brandGreen : .brandOrange)
                } else {
                    Text("—")
                        .font(.title3.bold())
                        .foregroundStyle(.tertiary)
                }
                Text("Protein")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 50)

            // Avg calories
            VStack(spacing: 4) {
                if let avg = viewModel.avgCalories(logs: logs) {
                    Text("\(Int(avg))")
                        .font(.title3.bold().monospacedDigit())
                        .foregroundStyle(avg <= Double(targetCalories) * 1.1 ? .brandGreen : .brandOrange)
                } else {
                    Text("—")
                        .font(.title3.bold())
                        .foregroundStyle(.tertiary)
                }
                Text("Calories")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 50)

            // Avg sleep
            VStack(spacing: 4) {
                if let avg = viewModel.avgSleep(logs: logs) {
                    Text(String(format: "%.1f", avg))
                        .font(.title3.bold().monospacedDigit())
                        .foregroundStyle(avg >= 7 ? .brandGreen : avg >= 5 ? .brandOrange : .brandRed)
                } else {
                    Text("—")
                        .font(.title3.bold())
                        .foregroundStyle(.tertiary)
                }
                Text("Sleep")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 50)

            // Sessions
            VStack(spacing: 4) {
                let done = viewModel.sessionsCompleted(logs: logs)
                Text("\(done)")
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(done >= 3 ? .brandGreen : .brandOrange)
                Text("Sessions")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .cardStyle(padding: 0)
    }
}
