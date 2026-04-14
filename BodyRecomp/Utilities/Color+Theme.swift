import SwiftUI

extension Color {
    // MARK: - Primary palette
    static let brandGreen = Color(red: 0.18, green: 0.78, blue: 0.44)
    static let brandGreenDim = Color(red: 0.18, green: 0.78, blue: 0.44).opacity(0.15)
    static let brandOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let brandRed = Color(red: 0.95, green: 0.27, blue: 0.27)
}

extension ShapeStyle where Self == Color {
    static var brandGreen: Color { Color.brandGreen }
    static var brandGreenDim: Color { Color.brandGreenDim }
    static var brandOrange: Color { Color.brandOrange }
    static var brandRed: Color { Color.brandRed }
    static var proteinColor: Color { Color.proteinColor }
    static var calorieColor: Color { Color.calorieColor }
    static var sleepColor: Color { Color.sleepColor }
    static var energyColor: Color { Color.energyColor }
}

extension Color {
    // MARK: - Semantic
    static let proteinColor = Color(red: 0.18, green: 0.78, blue: 0.44)   // green
    static let calorieColor = Color(red: 0.98, green: 0.73, blue: 0.18)   // amber
    static let sleepColor = Color(red: 0.42, green: 0.60, blue: 0.98)     // periwinkle
    static let energyColor = Color(red: 1.0, green: 0.58, blue: 0.0)      // orange

    // MARK: - Muscle groups
    static func muscleColor(_ group: MuscleGroup) -> Color {
        switch group {
        case .chest: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .back: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .shoulders: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case .triceps: return Color(red: 0.7, green: 0.3, blue: 0.8)
        case .biceps: return Color(red: 0.5, green: 0.3, blue: 0.9)
        case .legs: return Color(red: 0.2, green: 0.75, blue: 0.45)
        case .glutes: return Color(red: 0.2, green: 0.65, blue: 0.35)
        case .calves: return Color(red: 0.1, green: 0.55, blue: 0.3)
        case .core: return Color(red: 0.95, green: 0.45, blue: 0.2)
        }
    }
}

// MARK: - Card modifier shorthand
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
}
