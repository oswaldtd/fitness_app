import SwiftUI
import SwiftData

struct AuditView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyAudit.triggeredAt, order: .reverse) private var audits: [WeeklyAudit]
    @Query(sort: \DailyLog.date, order: .reverse) private var allLogs: [DailyLog]
    @Query(filter: #Predicate<MealPlan> { $0.isActive }) private var plans: [MealPlan]

    @State private var viewModel = AuditViewModel()
    @State private var showingPreAuditForm = false
    @State private var selectedAudit: WeeklyAudit?

    private var activePlan: MealPlan? { plans.first }
    private var mostRecentAudit: WeeklyAudit? { audits.first(where: { $0.status == .complete }) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    auditTriggerCard
                        .padding(.horizontal)

                    if let audit = audits.first, audit.status == .inProgress || audit.status == .pending {
                        AuditLoadingView()
                            .padding(.horizontal)
                    }

                    if let audit = audits.first, audit.status == .complete {
                        AuditResultView(
                            audit: audit,
                            activePlan: activePlan,
                            onApplyDiff: {
                                if let plan = activePlan {
                                    viewModel.applyDiff(from: audit, to: plan, context: modelContext)
                                }
                            }
                        )
                        .padding(.horizontal)
                    }

                    if audits.count > 1 {
                        pastAuditsSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Weekly Audit")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPreAuditForm) {
            preAuditForm
        }
        .alert("Audit Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var auditTriggerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Claude Audit")
                        .font(.headline)
                    Text(viewModel.isAuditAvailable
                         ? "Send this week's data to Claude for analysis"
                         : "Available on Sunday + Monday grace period")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.brandGreen)
            }

            Button {
                showingPreAuditForm = true
            } label: {
                HStack {
                    if viewModel.isRunning {
                        ProgressView().tint(.white)
                    }
                    Text(viewModel.auditButtonLabel)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    (viewModel.isAuditAvailable && !viewModel.isRunning)
                    ? Color.brandGreen : Color.secondary.opacity(0.3)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isAuditAvailable || viewModel.isRunning)

            #if DEBUG
            Button("Force Run (debug)") {
                showingPreAuditForm = true
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            #endif
        }
        .cardStyle()
    }

    private var preAuditForm: some View {
        NavigationStack {
            Form {
                Section("Before we run the audit…") {
                    HStack {
                        Text("Waist measurement")
                        Spacer()
                        TextField("inches", text: $viewModel.waistMeasurementIn)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("in")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("This week's adherence") {
                    ForEach(AdherenceGutCheck.allCases, id: \.self) { option in
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if viewModel.adherenceGutCheck == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.brandGreen)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.adherenceGutCheck = option }
                    }
                }
            }
            .navigationTitle("Check-in Answers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Run Audit") {
                        showingPreAuditForm = false
                        Task {
                            await viewModel.runAudit(
                                dailyLogs: Array(allLogs),
                                activePlan: activePlan,
                                previousAudit: mostRecentAudit,
                                context: modelContext
                            )
                        }
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingPreAuditForm = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var pastAuditsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Past Audits")
                .sectionHeader()
                .padding(.horizontal)

            ForEach(Array(audits.dropFirst()).prefix(4)) { audit in
                Button {
                    selectedAudit = audit
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Week of \(audit.weekStartDate.monthDayLabel)")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            if let response = audit.parsedResponse {
                                Text(response.recommendation)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
