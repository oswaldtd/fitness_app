import Foundation
import SwiftData
import Observation

@Observable
final class NutritionViewModel {
    var selectedDate: Date = Date()
    var showingDeviationSheet = false
    var deviationSlot: MealSlot?

    // MARK: - Meals for current day variant

    func mealsForVariant(_ variant: DayVariant, from plan: MealPlan) -> [MealSlot: Meal] {
        var result: [MealSlot: Meal] = [:]
        for meal in plan.meals {
            if meal.dayVariant == .both || meal.dayVariant == variant {
                // For slots that appear twice (dinner), prefer the variant-specific one
                if result[meal.slot] == nil || meal.dayVariant != .both {
                    result[meal.slot] = meal
                }
            }
        }
        return result
    }

    func sortedSlots() -> [MealSlot] {
        MealSlot.allCases.sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Macro totals for the day

    func planCalories(variant: DayVariant, plan: MealPlan) -> Int {
        mealsForVariant(variant, from: plan).values.reduce(0) { $0 + $1.totalCalories }
    }

    func planProtein(variant: DayVariant, plan: MealPlan) -> Double {
        mealsForVariant(variant, from: plan).values.reduce(0) { $0 + $1.totalProtein }
    }

    func actualCalories(log: DailyLog, variant: DayVariant, plan: MealPlan) -> Int {
        var total = planCalories(variant: variant, plan: plan)

        // Add completed gap-closers
        for addLog in log.additionLogs where addLog.completed {
            if let addition = plan.dailyAdditions.first(where: { $0.id == addLog.additionID }) {
                total += addition.calDelta
            }
        }

        // Add deviations
        for dev in log.deviationLogs {
            total += dev.calories ?? 0
        }

        return total
    }

    func actualProtein(log: DailyLog, variant: DayVariant, plan: MealPlan) -> Double {
        var total = planProtein(variant: variant, plan: plan)

        for addLog in log.additionLogs where addLog.completed {
            if let addition = plan.dailyAdditions.first(where: { $0.id == addLog.additionID }) {
                total += addition.proteinDeltaG
            }
        }

        for dev in log.deviationLogs {
            total += dev.proteinGrams ?? 0
        }

        return total
    }

    func calorieProgress(log: DailyLog, variant: DayVariant, plan: MealPlan) -> Double {
        guard plan.targetCal > 0 else { return 0 }
        return Double(actualCalories(log: log, variant: variant, plan: plan)) / Double(plan.targetCal)
    }

    func proteinProgress(log: DailyLog, variant: DayVariant, plan: MealPlan) -> Double {
        guard plan.targetProteinG > 0 else { return 0 }
        return actualProtein(log: log, variant: variant, plan: plan) / plan.targetProteinG
    }
}
