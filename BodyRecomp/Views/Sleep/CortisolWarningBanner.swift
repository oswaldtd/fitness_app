import SwiftUI

struct CortisolWarningBanner: View {
    let message: String
    @State private var isDismissed = false

    var body: some View {
        if !isDismissed {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.brandOrange)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Cortisol Alert")
                        .font(.subheadline.bold())
                        .foregroundStyle(.brandOrange)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    withAnimation { isDismissed = true }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.brandOrange.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.brandOrange.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
