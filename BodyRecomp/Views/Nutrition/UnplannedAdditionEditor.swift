import SwiftUI

struct UnplannedAdditionEditor: View {
    let dailyLog: DailyLog
    let onSave: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var description = ""
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var fatText = ""
    @State private var carbsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("What did you add?") {
                    TextField("Description (e.g. Handful of chips, extra protein bar)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Macros (estimate is fine)") {
                    macroField(label: "Calories", text: $caloriesText, unit: "kcal")
                    macroField(label: "Protein", text: $proteinText, unit: "g")
                    macroField(label: "Fat", text: $fatText, unit: "g")
                    macroField(label: "Carbs", text: $carbsText, unit: "g")
                }
            }
            .navigationTitle("Unplanned Addition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                        onSave()
                    }
                    .disabled(description.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func macroField(label: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
            Text(unit)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)
        }
    }

    private func save() {
        let dev = DeviationLog(
            deviationType: .unplanned,
            slot: nil,
            descriptionText: description,
            calories: Int(caloriesText),
            proteinGrams: Double(proteinText),
            fatGrams: Double(fatText),
            carbsGrams: Double(carbsText)
        )
        dev.dailyLog = dailyLog
        modelContext.insert(dev)
    }
}
