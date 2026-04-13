import SwiftUI

struct MuscleVolumeGrid: View {
    let sessionLogs: [SessionLog]

    private var volumeByMuscle: [MuscleGroup: Int] {
        var result: [MuscleGroup: Int] = [:]
        for session in sessionLogs {
            for setLog in session.setLogs {
                result[setLog.muscleGroup, default: 0] += 1
            }
        }
        return result
    }

    private var sortedGroups: [(MuscleGroup, Int)] {
        volumeByMuscle
            .sorted { $0.value > $1.value }
            .filter { $0.value > 0 }
    }

    private var maxSets: Int { sortedGroups.first?.1 ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week's Volume")
                .sectionHeader()

            if sortedGroups.isEmpty {
                HStack {
                    Spacer()
                    Text("No sets logged this week")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(sortedGroups, id: \.0) { group, sets in
                        HStack(spacing: 10) {
                            Text(group.displayName)
                                .font(.subheadline)
                                .frame(width: 80, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.tertiarySystemBackground))

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.muscleColor(group))
                                        .frame(width: geo.size.width * CGFloat(sets) / CGFloat(maxSets))
                                        .animation(.easeOut, value: sets)
                                }
                            }
                            .frame(height: 20)

                            Text("\(sets)")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}
