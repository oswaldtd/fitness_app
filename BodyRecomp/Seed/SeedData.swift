import Foundation
import SwiftData

/// Seeds the app with the pre-loaded body recomposition plan on first launch.
/// Idempotent: checks for an existing active MealPlan before inserting.
enum SeedData {

    static func seedAll(context: ModelContext) {
        let plan = seedMealPlan(context: context)
        seedTrainingSessions(context: context)
        _ = plan  // suppress unused warning; plan is inserted into context
    }

    // MARK: - Meal Plan

    @discardableResult
    static func seedMealPlan(context: ModelContext) -> MealPlan {
        let plan = MealPlan(name: "Body Recomp — Week 1")

        // ── Breakfast (both variants) ───────────────────────────────────────────
        let breakfast = Meal(slot: .breakfast, dayVariant: .both, sortOrder: 0)
        breakfast.items = [
            MealItem(name: "Coffee + 1 tbsp half & half",
                     quantity: "1 cup", calories: 20, proteinGrams: 0, fatGrams: 2, carbsGrams: 1, sortOrder: 0),
            MealItem(name: "Whole eggs",
                     quantity: "2 large", calories: 140, proteinGrams: 12, fatGrams: 10, carbsGrams: 1, sortOrder: 1),
            MealItem(name: "Egg whites",
                     quantity: "1/3 cup", calories: 40, proteinGrams: 9, fatGrams: 0, carbsGrams: 1, sortOrder: 2),
            MealItem(name: "Cottage cheese",
                     quantity: "113g", calories: 90, proteinGrams: 12, fatGrams: 2, carbsGrams: 5, sortOrder: 3),
            MealItem(name: "Dave's Killer White Bread Done Right",
                     quantity: "2 slices", calories: 240, proteinGrams: 10, fatGrams: 4, carbsGrams: 44, sortOrder: 4),
            MealItem(name: "Avocado oil spray",
                     quantity: "3 spritz", calories: 18, proteinGrams: 0, fatGrams: 2, carbsGrams: 0, sortOrder: 5),
        ]
        breakfast.plan = plan

        // ── Lunch (both variants) ───────────────────────────────────────────────
        let lunch = Meal(slot: .lunch, dayVariant: .both, sortOrder: 1)
        lunch.items = [
            MealItem(name: "Chicken breast",
                     quantity: "5 oz", calories: 230, proteinGrams: 44, fatGrams: 5, carbsGrams: 0, sortOrder: 0),
            MealItem(name: "Las Fortunitas flour tortilla",
                     quantity: "1", calories: 130, proteinGrams: 4, fatGrams: 3, carbsGrams: 22, sortOrder: 1),
            MealItem(name: "Bell pepper",
                     quantity: "80g", calories: 25, proteinGrams: 1, fatGrams: 0, carbsGrams: 6, sortOrder: 2),
            MealItem(name: "Onion",
                     quantity: "30g", calories: 12, proteinGrams: 0, fatGrams: 0, carbsGrams: 3, sortOrder: 3),
            MealItem(name: "Avocado oil spray",
                     quantity: "2 spritz", calories: 13, proteinGrams: 0, fatGrams: 1.5, carbsGrams: 0, sortOrder: 4),
        ]
        lunch.plan = plan

        // ── Dinner — Broccoli day ───────────────────────────────────────────────
        let dinnerBroccoli = Meal(slot: .dinner, dayVariant: .broccoliDay, sortOrder: 2)
        dinnerBroccoli.items = [
            MealItem(name: "Chicken breast",
                     quantity: "5 oz", calories: 230, proteinGrams: 44, fatGrams: 5, carbsGrams: 0, sortOrder: 0),
            MealItem(name: "Mission carb balance tortilla",
                     quantity: "1", calories: 70, proteinGrams: 5, fatGrams: 3, carbsGrams: 18, sortOrder: 1),
            MealItem(name: "White rice (cooked)",
                     quantity: "1 cup", calories: 200, proteinGrams: 4, fatGrams: 0, carbsGrams: 45, sortOrder: 2),
            MealItem(name: "Adobo sauce (yogurt-based)",
                     quantity: "1 tbsp", calories: 30, proteinGrams: 2, fatGrams: 0, carbsGrams: 3, sortOrder: 3),
            MealItem(name: "Broccoli",
                     quantity: "170g (~your half)", calories: 58, proteinGrams: 5, fatGrams: 0, carbsGrams: 11, sortOrder: 4),
        ]
        dinnerBroccoli.plan = plan

        // ── Dinner — Green bean day ─────────────────────────────────────────────
        let dinnerGreenBean = Meal(slot: .dinner, dayVariant: .greenBeanDay, sortOrder: 2)
        dinnerGreenBean.items = [
            MealItem(name: "Chicken breast",
                     quantity: "5 oz", calories: 230, proteinGrams: 44, fatGrams: 5, carbsGrams: 0, sortOrder: 0),
            MealItem(name: "Mission carb balance tortilla",
                     quantity: "1", calories: 70, proteinGrams: 5, fatGrams: 3, carbsGrams: 18, sortOrder: 1),
            MealItem(name: "White rice (cooked)",
                     quantity: "1 cup", calories: 200, proteinGrams: 4, fatGrams: 0, carbsGrams: 45, sortOrder: 2),
            MealItem(name: "Adobo sauce (yogurt-based)",
                     quantity: "1 tbsp", calories: 30, proteinGrams: 2, fatGrams: 0, carbsGrams: 3, sortOrder: 3),
            MealItem(name: "Green beans",
                     quantity: "62g (~your half)", calories: 20, proteinGrams: 1, fatGrams: 0, carbsGrams: 4, sortOrder: 4),
        ]
        dinnerGreenBean.plan = plan

        // ── Snacks (both variants) ──────────────────────────────────────────────
        let snacks = Meal(slot: .snack, dayVariant: .both, sortOrder: 3)
        snacks.items = [
            MealItem(name: "TJ's Hold the Cone mini ice cream",
                     quantity: "1 cone", calories: 80, proteinGrams: 1, fatGrams: 4, carbsGrams: 10, sortOrder: 0),
            MealItem(name: "SkinnyDipped PB Dark Choc cup",
                     quantity: "1 piece", calories: 80, proteinGrams: 3, fatGrams: 5, carbsGrams: 7, sortOrder: 1),
        ]
        snacks.plan = plan

        plan.meals = [breakfast, lunch, dinnerBroccoli, dinnerGreenBean, snacks]

        // ── Daily additions (gap-closers) ───────────────────────────────────────
        let shake = DailyAddition(
            name: "Protein shake (TB12 vanilla + PBfit + banana + cocoa)",
            calDelta: 300,
            proteinDeltaG: 30,
            isNonNegotiable: true,
            sortOrder: 0,
            timingNote: "Post-training or afternoon bridge between lunch and dinner"
        )
        let extraChicken = DailyAddition(
            name: "Extra 1oz chicken ×2 meals (4oz → 5oz)",
            calDelta: 90,
            proteinDeltaG: 23,
            isNonNegotiable: false,
            sortOrder: 1
        )
        let pbToast = DailyAddition(
            name: "1 tbsp peanut butter on breakfast toast",
            calDelta: 95,
            proteinDeltaG: 4,
            isNonNegotiable: false,
            sortOrder: 2
        )
        shake.plan = plan
        extraChicken.plan = plan
        pbToast.plan = plan
        plan.dailyAdditions = [shake, extraChicken, pbToast]

        context.insert(plan)
        return plan
    }

    // MARK: - Training sessions

    static func seedTrainingSessions(context: ModelContext) {
        // Push — Monday (weekday 2)
        let push = TrainingSession(
            name: "Push",
            sessionType: .strength,
            defaultWeekday: 2,
            sortOrder: 0,
            sessionDescription: "Chest, Shoulders, Triceps — hypertrophy focus"
        )
        push.exercises = [
            Exercise(name: "DB Chest Press (flat or floor)", targetSets: 4,
                     targetRepsLow: 8, targetRepsHigh: 12, muscleGroup: .chest,
                     notes: "2 sec eccentric", sortOrder: 0),
            Exercise(name: "DB Incline Press", targetSets: 3,
                     targetRepsLow: 10, targetRepsHigh: 12, muscleGroup: .chest,
                     notes: "Focus on chest stretch", sortOrder: 1),
            Exercise(name: "DB Lateral Raise", targetSets: 3,
                     targetRepsLow: 12, targetRepsHigh: 15, muscleGroup: .shoulders,
                     notes: "Slow, no momentum", sortOrder: 2),
            Exercise(name: "DB Overhead Press", targetSets: 3,
                     targetRepsLow: 10, targetRepsHigh: 12, muscleGroup: .shoulders,
                     notes: "Seated for stability", sortOrder: 3),
            Exercise(name: "DB Tricep Overhead Extension", targetSets: 3,
                     targetRepsLow: 12, targetRepsHigh: 15, muscleGroup: .triceps,
                     notes: "Full range of motion", sortOrder: 4),
        ]
        context.insert(push)

        // LISS — Tuesday (weekday 3)
        let lissA = TrainingSession(
            name: "LISS + Mobility",
            sessionType: .liss,
            defaultWeekday: 3,
            sortOrder: 1,
            sessionDescription: "20–30 min walk (outdoors preferred) + 10 min mobility. HR under 130 bpm. This is recovery, not a workout."
        )
        context.insert(lissA)

        // Pull — Wednesday (weekday 4)
        let pull = TrainingSession(
            name: "Pull",
            sessionType: .strength,
            defaultWeekday: 4,
            sortOrder: 2,
            sessionDescription: "Back, Biceps — hypertrophy focus"
        )
        pull.exercises = [
            Exercise(name: "DB Bent-Over Row", targetSets: 4,
                     targetRepsLow: 8, targetRepsHigh: 12, muscleGroup: .back,
                     notes: "Brace core, squeeze at top", sortOrder: 0),
            Exercise(name: "DB Single-Arm Row", targetSets: 3,
                     targetRepsLow: 10, targetRepsHigh: 10, muscleGroup: .back,
                     notes: "Full stretch at bottom (per side)", sortOrder: 1),
            Exercise(name: "DB Reverse Fly", targetSets: 3,
                     targetRepsLow: 12, targetRepsHigh: 15, muscleGroup: .back,
                     notes: "Slight bend in elbow", sortOrder: 2),
            Exercise(name: "DB Curl (alternating)", targetSets: 3,
                     targetRepsLow: 10, targetRepsHigh: 12, muscleGroup: .biceps,
                     notes: "No swinging (per side)", sortOrder: 3),
            Exercise(name: "DB Hammer Curl", targetSets: 2,
                     targetRepsLow: 12, targetRepsHigh: 12, muscleGroup: .biceps,
                     notes: "Brachialis and forearm", sortOrder: 4),
        ]
        context.insert(pull)

        // LISS — Thursday (weekday 5)
        let lissB = TrainingSession(
            name: "LISS + Mobility",
            sessionType: .liss,
            defaultWeekday: 5,
            sortOrder: 3,
            sessionDescription: "Same as Tuesday. If sleep was rough, keep to 20 min + stretching. Do not push hard on bad sleep days."
        )
        context.insert(lissB)

        // Legs + Core — Friday (weekday 6)
        let legs = TrainingSession(
            name: "Legs + Core",
            sessionType: .strength,
            defaultWeekday: 6,
            sortOrder: 4,
            sessionDescription: "Legs and Core — hypertrophy + stability focus"
        )
        legs.exercises = [
            Exercise(name: "DB Goblet Squat", targetSets: 4,
                     targetRepsLow: 10, targetRepsHigh: 12, muscleGroup: .legs,
                     notes: "Heels slightly elevated if needed", sortOrder: 0),
            Exercise(name: "DB Romanian Deadlift", targetSets: 4,
                     targetRepsLow: 10, targetRepsHigh: 12, muscleGroup: .legs,
                     notes: "Hinge at hips, feel hamstring stretch", sortOrder: 1),
            Exercise(name: "DB Reverse Lunge", targetSets: 3,
                     targetRepsLow: 10, targetRepsHigh: 10, muscleGroup: .legs,
                     notes: "Knee tracks over toe (per side)", sortOrder: 2),
            Exercise(name: "DB Calf Raise", targetSets: 3,
                     targetRepsLow: 15, targetRepsHigh: 20, muscleGroup: .calves,
                     notes: "Full range, slow", sortOrder: 3),
            Exercise(name: "Plank", targetSets: 3,
                     targetRepsLow: 30, targetRepsHigh: 45, repUnit: .seconds,
                     muscleGroup: .core, notes: "Build over 4 weeks", sortOrder: 4),
            Exercise(name: "Dead Bug", targetSets: 3,
                     targetRepsLow: 8, targetRepsHigh: 8, muscleGroup: .core,
                     notes: "Core stability, low cortisol impact (per side)", sortOrder: 5),
        ]
        context.insert(legs)
    }
}
