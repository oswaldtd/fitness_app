import Foundation

enum DayVariant: String, Codable, CaseIterable {
    case broccoliDay = "broccoli_day"
    case greenBeanDay = "green_bean_day"
    case both

    var displayName: String {
        switch self {
        case .broccoliDay: return "Broccoli Day"
        case .greenBeanDay: return "Green Bean Day"
        case .both: return "Both"
        }
    }
}

enum MealSlot: String, Codable, CaseIterable {
    case breakfast, lunch, dinner, snack

    var displayName: String { rawValue.capitalized }

    var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        case .snack: return 3
        }
    }

    var emoji: String {
        switch self {
        case .breakfast: return "☀️"
        case .lunch: return "🌤"
        case .dinner: return "🌙"
        case .snack: return "🍎"
        }
    }
}

enum SessionType: String, Codable {
    case strength, liss
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest, back, shoulders, triceps, biceps, legs, glutes, calves, core

    var displayName: String { rawValue.capitalized }

    var emoji: String {
        switch self {
        case .chest: return "💪"
        case .back: return "🏋️"
        case .shoulders: return "🔝"
        case .triceps: return "💪"
        case .biceps: return "💪"
        case .legs: return "🦵"
        case .glutes: return "🍑"
        case .calves: return "🦵"
        case .core: return "🎯"
        }
    }
}

enum DeviationType: String, Codable {
    case substitution, offPlan, unplanned

    var displayName: String {
        switch self {
        case .substitution: return "Substitution"
        case .offPlan: return "Off-Plan Meal"
        case .unplanned: return "Unplanned Addition"
        }
    }

    var icon: String {
        switch self {
        case .substitution: return "arrow.triangle.2.circlepath"
        case .offPlan: return "fork.knife"
        case .unplanned: return "plus.circle"
        }
    }
}

enum RepUnit: String, Codable {
    case reps, seconds
}

enum MealLogStatus: String, Codable {
    case onPlan, deviated, skipped
}

enum AuditStatus: String, Codable {
    case pending, inProgress, complete, failed
}

enum AdherenceGutCheck: String, Codable, CaseIterable {
    case honest, mostly, struggled

    var displayName: String {
        switch self {
        case .honest: return "Honest — nailed it"
        case .mostly: return "Mostly — a few slips"
        case .struggled: return "Struggled — rough week"
        }
    }
}
