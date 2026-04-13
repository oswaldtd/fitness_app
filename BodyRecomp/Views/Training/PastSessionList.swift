import SwiftUI
import SwiftData

struct PastSessionList: View {
    @Query(sort: \DailyLog.date, order: .reverse) private var allLogs: [DailyLog]
    @Environment(\.dismiss) private var dismiss

    private var logsWithSessions: [DailyLog] {
        allLogs.filter { $0.sessionLog != nil }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(logsWithSessions) { log in
                    if let session = log.sessionLog {
                        NavigationLink {
                            pastSessionDetail(session: session, date: log.date)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(session.sessionName)
                                        .font(.headline)
                                    Text(log.date.monthDayLabel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 3) {
                                    Text("\(session.totalSets) sets")
                                        .font(.subheadline.monospacedDigit())
                                    if let effort = session.perceivedEffort {
                                        Text("Effort \(effort)/5")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func pastSessionDetail(session: SessionLog, date: Date) -> some View {
        List {
            Section {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(date.monthDayLabel).foregroundStyle(.secondary)
                }
                if let effort = session.perceivedEffort {
                    HStack {
                        Text("Effort")
                        Spacer()
                        Text("\(effort) / 5").foregroundStyle(.secondary)
                    }
                }
                if !session.notes.isEmpty {
                    HStack(alignment: .top) {
                        Text("Notes")
                        Spacer()
                        Text(session.notes).foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }

            let grouped = Dictionary(grouping: session.setLogs.sorted { $0.setNumber < $1.setNumber }, by: { $0.exerciseName })
            ForEach(grouped.keys.sorted(), id: \.self) { name in
                Section(name) {
                    ForEach(grouped[name] ?? []) { setLog in
                        HStack {
                            Text("Set \(setLog.setNumber)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(setLog.repsCompleted) reps")
                                .monospacedDigit()
                            if let w = setLog.weightLbs {
                                Text("@ \(w, specifier: "%.1f") lbs")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(session.sessionName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
