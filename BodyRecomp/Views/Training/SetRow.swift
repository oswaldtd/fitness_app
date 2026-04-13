import SwiftUI

struct SetRow: View {
    let setLog: SetLog
    let exercise: Exercise

    var body: some View {
        HStack {
            Text("Set \(setLog.setNumber)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)

            Text("\(setLog.repsCompleted) \(exercise.repUnit == .seconds ? "sec" : "reps")")
                .font(.subheadline.monospacedDigit())

            if let weight = setLog.weightLbs {
                Text("@ \(weight, specifier: "%.1f") lbs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(.brandGreen)
        }
        .padding(.horizontal, 4)
    }
}
