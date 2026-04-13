import SwiftUI
import SwiftData

struct SubstitutionEditor: View {
    let slot: MealSlot
    let dailyLog: DailyLog
    let onSave: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [Favorites]

    @State private var foodName = ""
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var fatText = ""
    @State private var carbsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("What did you eat instead?") {
                    TextField("Food name (e.g. Salmon fillet)", text: $foodName)
                        .autocorrectionDisabled()
                }

                Section("Macros (whole meal totals)") {
                    macroField(label: "Calories", text: $caloriesText, unit: "kcal")
                    macroField(label: "Protein", text: $proteinText, unit: "g")
                    macroField(label: "Fat", text: $fatText, unit: "g")
                    macroField(label: "Carbs", text: $carbsText, unit: "g")
                }

                if !favorites.isEmpty {
                    Section("Recent favorites") {
                        ForEach(favorites.sorted { $0.useCount > $1.useCount }.prefix(5)) { fav in
                            Button {
                                foodName = fav.name
                                caloriesText = "\(fav.calories)"
                                proteinText = "\(Int(fav.proteinGrams))"
                                fatText = "\(Int(fav.fatGrams))"
                                carbsText = "\(Int(fav.carbsGrams))"
                            } label: {
                                HStack {
                                    Text(fav.name)
                                    Spacer()
                                    Text("\(fav.calories) cal")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Substitution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                        onSave()
                    }
                    .disabled(foodName.isEmpty)
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
            deviationType: .substitution,
            slot: slot,
            descriptionText: foodName,
            calories: Int(caloriesText),
            proteinGrams: Double(proteinText),
            fatGrams: Double(fatText),
            carbsGrams: Double(carbsText)
        )
        dev.dailyLog = dailyLog
        context.insert(dev)
        updateFavorites()
    }

    private var context: ModelContext { modelContext }

    private func updateFavorites() {
        let cal = Int(caloriesText) ?? 0
        let prot = Double(proteinText) ?? 0
        if let existing = favorites.first(where: { $0.name.lowercased() == foodName.lowercased() }) {
            existing.useCount += 1
            existing.lastUsedAt = Date()
        } else if cal > 0 {
            let fav = Favorites(
                name: foodName,
                calories: cal,
                proteinGrams: prot,
                fatGrams: Double(fatText) ?? 0,
                carbsGrams: Double(carbsText) ?? 0
            )
            modelContext.insert(fav)
        }
    }
}
