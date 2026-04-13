import SwiftUI
import SwiftData

struct DayDetailSheet: View {
    let date: Date
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = WeekViewModel()
    @State private var dailyLog: DailyLog?

    // Bindings to the log fields (use local @State, sync to log)
    @State private var proteinText = ""
    @State private var caloriesText = ""
    @State private var sleepScore: Double = 7
    @State private var energyScore: Double = 7
    @State private var workoutDone = false
    @State private var shakeDone = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Inputs — \(date.monthDayLabel)") {
                    HStack {
                        Label("Protein", systemImage: "p.circle.fill")
                            .foregroundStyle(.proteinColor)
                        Spacer()
                        TextField("0", text: $proteinText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Calories", systemImage: "flame.fill")
                            .foregroundStyle(.calorieColor)
                        Spacer()
                        TextField("0", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Sleep quality", systemImage: "moon.fill")
                                .foregroundStyle(.sleepColor)
                            Spacer()
                            Text("\(Int(sleepScore)) / 10")
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.sleepColor)
                        }
                        Slider(value: $sleepScore, in: 1...10, step: 1)
                            .tint(.sleepColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Energy level", systemImage: "bolt.fill")
                                .foregroundStyle(.energyColor)
                            Spacer()
                            Text("\(Int(energyScore)) / 10")
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.energyColor)
                        }
                        Slider(value: $energyScore, in: 1...10, step: 1)
                            .tint(.energyColor)
                    }
                }

                Section("Completion") {
                    Toggle(isOn: $workoutDone) {
                        Label("Workout done", systemImage: "dumbbell.fill")
                    }
                    .tint(.brandGreen)

                    Toggle(isOn: $shakeDone) {
                        HStack {
                            Label("Protein shake", systemImage: "cup.and.saucer.fill")
                            Spacer(minLength: 4)
                            Text("non-negotiable")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .tint(.brandGreen)
                }
            }
            .navigationTitle(date.isToday ? "Today" : date.monthDayLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { loadOrCreate() }
        }
    }

    private func loadOrCreate() {
        let log = viewModel.findOrCreate(date: date, context: modelContext)
        dailyLog = log

        if let p = log.proteinGrams { proteinText = "\(Int(p))" }
        if let c = log.caloriesConsumed { caloriesText = "\(c)" }
        if let s = log.sleepQuality { sleepScore = Double(s) }
        if let e = log.energyLevel { energyScore = Double(e) }
        workoutDone = log.workoutCompleted
        shakeDone = log.shakeCompleted
    }

    private func save() {
        guard let log = dailyLog else { return }

        if let p = Double(proteinText) { log.proteinGrams = p }
        if let c = Int(caloriesText) { log.caloriesConsumed = c }
        log.sleepQuality = Int(sleepScore)
        log.energyLevel = Int(energyScore)
        log.workoutCompleted = workoutDone

        // Sync shake toggle to AdditionLog
        if let shakeLog = log.additionLogs.first(where: { $0.isShake }) {
            shakeLog.completed = shakeDone
            if shakeDone { shakeLog.loggedAt = Date() }
        }
    }
}
