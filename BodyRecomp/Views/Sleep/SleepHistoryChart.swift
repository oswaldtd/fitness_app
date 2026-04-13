import SwiftUI
import Charts

struct SleepHistoryChart: View {
    let dataPoints: [SleepViewModel.SleepDataPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("7-Day Sleep Quality")
                .font(.headline)

            Chart {
                RuleMark(y: .value("Target", 7))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Color.brandGreen.opacity(0.4))

                ForEach(dataPoints) { point in
                    AreaMark(
                        x: .value("Day", point.date),
                        y: .value("Score", point.score)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.sleepColor.opacity(0.3), Color.sleepColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", point.date),
                        y: .value("Score", point.score)
                    )
                    .foregroundStyle(Color.sleepColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Day", point.date),
                        y: .value("Score", point.score)
                    )
                    .foregroundStyle(point.score >= 7 ? Color.brandGreen : point.score >= 5 ? Color.brandOrange : Color.brandRed)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.shortDayLabel)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [2, 4, 6, 8, 10]) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartYScale(domain: 0...10)
            .frame(height: 140)
        }
        .cardStyle()
    }
}
