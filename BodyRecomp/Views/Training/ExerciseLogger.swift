import SwiftUI

struct ExerciseLogger: View {
    let exercise: Exercise
    let sessionLog: SessionLog
    let viewModel: TrainingViewModel

    @Environment(\.modelContext) private var modelContext
    @State private var repsInput = ""
    @State private var weightInput = ""

    private var loggedSets: [SetLog] {
        viewModel.setsLogged(for: exercise, in: sessionLog)
    }

    private var nextSetNumber: Int { loggedSets.count + 1 }
    private var isComplete: Bool { loggedSets.count >= exercise.targetSets }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                    Text("Target: \(exercise.setsRepsLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(loggedSets.count)/\(exercise.targetSets) sets")
                    .font(.caption.monospacedDigit())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isComplete ? Color.brandGreen.opacity(0.15) : Color(.tertiarySystemBackground))
                    .foregroundStyle(isComplete ? .brandGreen : .secondary)
                    .clipShape(Capsule())
            }

            // Logged sets
            if !loggedSets.isEmpty {
                VStack(spacing: 4) {
                    ForEach(loggedSets) { set in
                        SetRow(setLog: set, exercise: exercise)
                    }
                }
            }

            // Add set row
            if !isComplete && sessionLog.completedAt == nil {
                HStack(spacing: 8) {
                    TextField(exercise.repsDisplay, text: $repsInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .overlay(alignment: .trailing) {
                            Text(exercise.repUnit == .seconds ? "s" : "reps")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 6)
                        }

                    TextField("lbs", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Spacer()

                    Button {
                        logSet()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(repsInput.isEmpty ? .secondary : .brandGreen)
                    }
                    .disabled(repsInput.isEmpty)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func logSet() {
        guard let reps = Int(repsInput) else { return }
        let weight = Double(weightInput)
        viewModel.addSet(
            to: sessionLog,
            exercise: exercise,
            reps: reps,
            weight: weight,
            context: modelContext
        )
        repsInput = ""
        weightInput = ""
    }
}
