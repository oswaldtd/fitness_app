import SwiftUI

// MARK: - Section header
struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

extension View {
    func sectionHeader() -> some View {
        modifier(SectionHeader())
    }
}

// MARK: - Stat pill
struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Loading overlay
struct LoadingOverlay: ViewModifier {
    let isLoading: Bool
    let message: String

    func body(content: Content) -> some View {
        content.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.4)
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(28)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String = "Loading…") -> some View {
        modifier(LoadingOverlay(isLoading: isLoading, message: message))
    }
}

// MARK: - Numeric ring
struct RingProgress: View {
    let value: Double      // 0.0 – 1.0
    let color: Color
    let lineWidth: CGFloat
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(value, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: value)
        }
        .frame(width: size, height: size)
    }
}
