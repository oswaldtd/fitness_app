import SwiftUI

struct SessionCard: View {
    let session: TrainingSession
    let existingLog: SessionLog?
    let onStart: () -> Void
    let onComplete: (SessionLog) -> Void
    let viewModel: TrainingViewModel

    @State private var isExpanded = true
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: session.sessionType == .strength ? "dumbbell.fill" : "figure.walk")
                            .foregroundStyle(.brandGreen)
                        Text(session.name)
                            .font(.title3.bold())
                    }
                    Text(session.sessionDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()

            if isExpanded {
                if session.sessionType == .liss {
                    lissContent
                } else if let log = existingLog {
                    activeSessionContent(log: log)
                } else {
                    preSessionContent
                }
            }
        }
        .cardStyle(padding: 0)
    }

    private var lissContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().padding(.horizontal)
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundStyle(.brandGreen)
                Text("20–30 min walk · HR under 130 bpm · 10 min mobility after")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private var preSessionContent: some View {
        VStack(spacing: 12) {
            Divider().padding(.horizontal)
            ForEach(session.exercises.sorted { $0.sortOrder < $1.sortOrder }) { exercise in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name)
                            .font(.subheadline)
                        if !exercise.notes.isEmpty {
                            Text(exercise.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(exercise.setsRepsLabel)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.brandGreen)
                }
                .padding(.horizontal)
            }
            Button {
                onStart()
            } label: {
                Text("Start Session")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.brandGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func activeSessionContent(log: SessionLog) -> some View {
        VStack(spacing: 0) {
            Divider().padding(.horizontal)
            ForEach(session.exercises.sorted { $0.sortOrder < $1.sortOrder }) { exercise in
                ExerciseLogger(
                    exercise: exercise,
                    sessionLog: log,
                    viewModel: viewModel
                )
                Divider().padding(.horizontal)
            }
            if log.completedAt == nil {
                Button {
                    onComplete(log)
                } label: {
                    Text("Complete Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.brandGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.brandGreen)
                    Text("Session complete")
                        .foregroundStyle(.brandGreen)
                    if let effort = log.perceivedEffort {
                        Text("· Effort \(effort)/5")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)
                .padding()
            }
        }
    }
}
