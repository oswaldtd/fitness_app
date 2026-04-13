import SwiftUI

struct AuditLoadingView: View {
    @State private var dots = ""
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 16) {
            ProgressView()
                .tint(.brandGreen)
            VStack(alignment: .leading, spacing: 4) {
                Text("Analyzing your week\(dots)")
                    .font(.subheadline.weight(.semibold))
                Text("Claude is reviewing your data…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .cardStyle(padding: 0)
        .padding(.top, -8)
        .onReceive(timer) { _ in
            dots = dots.count < 3 ? dots + "." : ""
        }
    }
}
