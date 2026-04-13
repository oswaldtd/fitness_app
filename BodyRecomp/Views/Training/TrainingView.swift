import SwiftUI
import SwiftData

struct TrainingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [TrainingSession]
    @Query private var allLogs: [DailyLog]

    @State private var viewModel = TrainingViewModel()
    @State private var showingPastSessions = false
    @State private var activeSessionLog: SessionLog?
    @State private var showingEffortSheet = false
    @State private var effortRating: Double = 3
    @State private var sessionNotes = ""

    private var todayLog: DailyLog? {
        allLogs.first(where: { Calendar.current.isDateInToday($0.date) })
    }

    private var todaySession: TrainingSession? {
        viewModel.todaySession(from: sessions)
    }

    private var weekSessionLogs: [SessionLog] {
        let weekDays = Date().weekDays
        return allLogs
            .filter { log in weekDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: log.date) }) }
            .compactMap { $0.sessionLog }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isRestDay {
                        restDayView
                    } else if let session = todaySession {
                        SessionCard(
                            session: session,
                            existingLog: todayLog?.sessionLog,
                            onStart: { startSession(session: session) },
                            onComplete: { log in
                                activeSessionLog = log
                                showingEffortSheet = true
                            },
                            viewModel: viewModel
                        )
                        .padding(.horizontal)
                    } else {
                        noSessionView
                    }

                    MuscleVolumeGrid(sessionLogs: weekSessionLogs)
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("History") { showingPastSessions = true }
                }
            }
        }
        .sheet(isPresented: $showingPastSessions) {
            PastSessionList()
        }
        .sheet(isPresented: $showingEffortSheet) {
            effortSheet
        }
    }

    private var restDayView: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48))
                .foregroundStyle(.sleepColor)
            Text(viewModel.isOptionalWalkDay ? "Optional Walk Day" : "Full Rest Day")
                .font(.title2.bold())
            Text(viewModel.isOptionalWalkDay
                 ? "A short walk or stretch is great. No formal session today."
                 : "Rest, sleep, recover. Training works when you rest.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 48)
    }

    private var noSessionView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No session found for today")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 32)
    }

    private var effortSheet: some View {
        NavigationStack {
            Form {
                Section("How was that session?") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Effort rating")
                            Spacer()
                            Text("\(Int(effortRating)) / 5")
                                .monospacedDigit()
                                .foregroundStyle(.brandGreen)
                        }
                        Slider(value: $effortRating, in: 1...5, step: 1)
                            .tint(.brandGreen)
                    }
                }
                Section("Notes (optional)") {
                    TextField("Form cues, fatigue flags, PRs…", text: $sessionNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Complete Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let log = activeSessionLog, let dayLog = todayLog {
                            viewModel.completeSession(log, effort: Int(effortRating), notes: sessionNotes, dailyLog: dayLog)
                        }
                        showingEffortSheet = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingEffortSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func startSession(session: TrainingSession) {
        let dayLog = WeekViewModel().findOrCreate(date: Date(), context: modelContext)
        _ = viewModel.startSession(for: session, dailyLog: dayLog, context: modelContext)
    }
}
