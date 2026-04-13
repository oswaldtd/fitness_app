import SwiftUI
import SwiftData

struct DeviationSheet: View {
    let slot: MealSlot
    let dailyLog: DailyLog

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: DeviationType = .substitution
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Logging a deviation for \(slot.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Type") {
                    ForEach(DeviationType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                            showingEditor = true
                        } label: {
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundStyle(.brandGreen)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(typeDescription(type))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Add Deviation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingEditor) {
                deviationEditor(for: selectedType)
            }
        }
    }

    @ViewBuilder
    private func deviationEditor(for type: DeviationType) -> some View {
        switch type {
        case .substitution:
            SubstitutionEditor(slot: slot, dailyLog: dailyLog, onSave: { dismiss() })
        case .offPlan:
            OffPlanMealEditor(slot: slot, dailyLog: dailyLog, onSave: { dismiss() })
        case .unplanned:
            UnplannedAdditionEditor(dailyLog: dailyLog, onSave: { dismiss() })
        }
    }

    private func typeDescription(_ type: DeviationType) -> String {
        switch type {
        case .substitution: return "Swapped one food for another in this slot"
        case .offPlan: return "Replaced this whole meal with something else"
        case .unplanned: return "Added something outside this meal slot"
        }
    }
}

extension DeviationType: CaseIterable {
    public static var allCases: [DeviationType] { [.substitution, .offPlan, .unplanned] }
}
