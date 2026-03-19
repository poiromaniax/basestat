import Foundation

enum AchievementCatalog {
    static let all: [AchievementDefinition] = weight + steps + exercise + sleep + heart + meta + records

    // MARK: - Weight
    static let weight: [AchievementDefinition] = [
        AchievementDefinition(
            id: "weight.first_weigh_in",
            title: "First Weigh-In",
            description: "Log your first weight measurement.",
            icon: "scalemass.fill",
            category: .weight, xpReward: 50, rarity: .common
        ),
        AchievementDefinition(
            id: "weight.lost_1kg",
            title: "First Kilo Down",
            description: "Lose your first kilogram.",
            icon: "arrow.down.circle.fill",
            category: .weight, xpReward: 100, rarity: .common
        ),
        AchievementDefinition(
            id: "weight.lost_5kg",
            title: "5 Kilos Crushed",
            description: "Lose 5 kilograms from your starting weight.",
            icon: "5.circle.fill",
            category: .weight, xpReward: 300, rarity: .rare
        ),
        AchievementDefinition(
            id: "weight.lost_10kg",
            title: "10 Kilos Legend",
            description: "Lose 10 kilograms from your starting weight.",
            icon: "trophy.fill",
            category: .weight, xpReward: 750, rarity: .epic
        ),
        AchievementDefinition(
            id: "weight.lost_25kg",
            title: "Transformation King",
            description: "Lose 25 kilograms. Absolutely legendary.",
            icon: "crown.fill",
            category: .weight, xpReward: 2000, rarity: .legendary
        ),
        AchievementDefinition(
            id: "weight.goal_reached",
            title: "Goal Weight Achieved",
            description: "Reach your target weight goal.",
            icon: "checkmark.seal.fill",
            category: .weight, xpReward: 1500, rarity: .legendary
        ),
        AchievementDefinition(
            id: "weight.consistent_7",
            title: "Scale Habit",
            description: "Log weight 7 days in a row.",
            icon: "calendar.badge.checkmark",
            category: .weight, xpReward: 150, rarity: .common
        )
    ]

    // MARK: - Steps
    static let steps: [AchievementDefinition] = [
        AchievementDefinition(
            id: "steps.first_10k",
            title: "10,000 Steps!",
            description: "Complete your first 10,000 step day.",
            icon: "figure.walk.circle.fill",
            category: .steps, xpReward: 100, rarity: .common
        ),
        AchievementDefinition(
            id: "steps.streak_7",
            title: "Step Streak: 7",
            description: "Hit 10,000 steps for 7 days in a row.",
            icon: "flame.fill",
            category: .steps, xpReward: 350, rarity: .rare
        ),
        AchievementDefinition(
            id: "steps.streak_30",
            title: "Step Streak: 30",
            description: "Hit 10,000 steps for 30 days in a row.",
            icon: "bolt.fill",
            category: .steps, xpReward: 1000, rarity: .epic
        ),
        AchievementDefinition(
            id: "steps.week_70k",
            title: "70K Week",
            description: "Walk 70,000 steps in a single week.",
            icon: "figure.walk.motion",
            category: .steps, xpReward: 400, rarity: .rare
        ),
        AchievementDefinition(
            id: "steps.million",
            title: "Million Stepper",
            description: "Accumulate 1,000,000 total steps.",
            icon: "star.circle.fill",
            category: .steps, xpReward: 2500, rarity: .legendary
        )
    ]

    // MARK: - Exercise
    static let exercise: [AchievementDefinition] = [
        AchievementDefinition(
            id: "exercise.first_workout",
            title: "First Sweat",
            description: "Complete your first workout.",
            icon: "dumbbell.fill",
            category: .exercise, xpReward: 75, rarity: .common
        ),
        AchievementDefinition(
            id: "exercise.workouts_10",
            title: "10 Workouts",
            description: "Complete 10 workouts.",
            icon: "10.circle.fill",
            category: .exercise, xpReward: 250, rarity: .common
        ),
        AchievementDefinition(
            id: "exercise.workouts_50",
            title: "50 Workouts",
            description: "Complete 50 workouts.",
            icon: "50.circle.fill",
            category: .exercise, xpReward: 750, rarity: .rare
        ),
        AchievementDefinition(
            id: "exercise.workouts_100",
            title: "Century Club",
            description: "Complete 100 workouts. You're unstoppable.",
            icon: "100.circle.fill",
            category: .exercise, xpReward: 1500, rarity: .epic
        ),
        AchievementDefinition(
            id: "exercise.streak_7",
            title: "Exercise Streak: 7",
            description: "Exercise 7 days in a row.",
            icon: "bolt.circle.fill",
            category: .exercise, xpReward: 300, rarity: .rare
        ),
        AchievementDefinition(
            id: "exercise.streak_30",
            title: "Iron Will",
            description: "Exercise 30 days in a row.",
            icon: "shield.fill",
            category: .exercise, xpReward: 1200, rarity: .epic
        ),
        AchievementDefinition(
            id: "exercise.active_1hour",
            title: "Hour of Power",
            description: "Exercise for 60 minutes in a single day.",
            icon: "timer.circle.fill",
            category: .exercise, xpReward: 200, rarity: .common
        )
    ]

    // MARK: - Sleep
    static let sleep: [AchievementDefinition] = [
        AchievementDefinition(
            id: "sleep.first_8hours",
            title: "Sweet Dreams",
            description: "Get 8 hours of sleep.",
            icon: "moon.zzz.fill",
            category: .sleep, xpReward: 100, rarity: .common
        ),
        AchievementDefinition(
            id: "sleep.streak_7",
            title: "Sleep Champion",
            description: "Get 7+ hours of sleep for 7 days in a row.",
            icon: "bed.double.fill",
            category: .sleep, xpReward: 350, rarity: .rare
        ),
        AchievementDefinition(
            id: "sleep.streak_30",
            title: "Sleep Guru",
            description: "Get 7+ hours of sleep for 30 days in a row.",
            icon: "sparkles",
            category: .sleep, xpReward: 1000, rarity: .epic
        )
    ]

    // MARK: - Heart
    static let heart: [AchievementDefinition] = [
        AchievementDefinition(
            id: "heart.first_reading",
            title: "Heart Check",
            description: "Get your first heart rate reading.",
            icon: "heart.fill",
            category: .heart, xpReward: 50, rarity: .common
        ),
        AchievementDefinition(
            id: "heart.resting_below_60",
            title: "Athlete Heart",
            description: "Achieve a resting heart rate below 60 bpm.",
            icon: "heart.circle.fill",
            category: .heart, xpReward: 500, rarity: .epic
        ),
        AchievementDefinition(
            id: "heart.improved_hr",
            title: "Heart Health",
            description: "Improve your resting heart rate by 5 bpm.",
            icon: "waveform.path.ecg",
            category: .heart, xpReward: 300, rarity: .rare
        )
    ]

    // MARK: - Meta / Milestones
    static let meta: [AchievementDefinition] = [
        AchievementDefinition(
            id: "meta.streak_7",
            title: "Week Warrior",
            description: "Use BaseStat for 7 days in a row.",
            icon: "7.circle.fill",
            category: .meta, xpReward: 100, rarity: .common
        ),
        AchievementDefinition(
            id: "meta.streak_30",
            title: "Monthly Master",
            description: "Use BaseStat for 30 days in a row.",
            icon: "calendar.circle.fill",
            category: .meta, xpReward: 500, rarity: .rare
        ),
        AchievementDefinition(
            id: "meta.streak_100",
            title: "100 Day Hero",
            description: "Use BaseStat for 100 days in a row.",
            icon: "crown.fill",
            category: .meta, xpReward: 2000, rarity: .legendary
        ),
        AchievementDefinition(
            id: "meta.level_10",
            title: "Level 10 Warrior",
            description: "Reach level 10.",
            icon: "10.circle.fill",
            category: .meta, xpReward: 500, rarity: .rare
        ),
        AchievementDefinition(
            id: "meta.level_25",
            title: "Level 25 Champion",
            description: "Reach level 25.",
            icon: "25.circle.fill",
            category: .meta, xpReward: 1500, rarity: .epic
        ),
        AchievementDefinition(
            id: "meta.level_50",
            title: "Level 50 Legend",
            description: "Reach level 50. True immortal status.",
            icon: "50.circle.fill",
            category: .meta, xpReward: 5000, rarity: .legendary
        ),
        AchievementDefinition(
            id: "meta.first_login",
            title: "The Journey Begins",
            description: "Welcome to BaseStat! Your legend starts here.",
            icon: "figure.run",
            category: .meta, xpReward: 25, rarity: .common
        )
    ]

    // MARK: - Personal Records
    static let records: [AchievementDefinition] = [
        AchievementDefinition(
            id: "pr.lowest_weight",
            title: "Lightest Ever",
            description: "Hit your all-time lowest recorded weight.",
            icon: "scalemass.fill",
            category: .records, xpReward: 500, rarity: .epic
        ),
        AchievementDefinition(
            id: "pr.steps_20k",
            title: "20K Day",
            description: "Walk 20,000 steps in a single day.",
            icon: "figure.walk.circle.fill",
            category: .records, xpReward: 200, rarity: .rare
        ),
        AchievementDefinition(
            id: "pr.steps_30k",
            title: "30K Crusher",
            description: "Walk 30,000 steps in a single day.",
            icon: "figure.run",
            category: .records, xpReward: 500, rarity: .epic
        ),
        AchievementDefinition(
            id: "pr.steps_50k",
            title: "Ultra Walker",
            description: "Walk 50,000 steps in a single day.",
            icon: "trophy.fill",
            category: .records, xpReward: 1500, rarity: .legendary
        ),
        AchievementDefinition(
            id: "pr.calories_1000",
            title: "1000 Cal Burn",
            description: "Burn 1,000 active calories in a single day.",
            icon: "bolt.fill",
            category: .records, xpReward: 300, rarity: .rare
        ),
        AchievementDefinition(
            id: "pr.calories_2000",
            title: "Inferno Day",
            description: "Burn 2,000 active calories in a single day.",
            icon: "flame.fill",
            category: .records, xpReward: 750, rarity: .epic
        ),
        AchievementDefinition(
            id: "pr.workout_60min",
            title: "Hour of Iron",
            description: "Complete a single workout lasting 60 minutes.",
            icon: "dumbbell.fill",
            category: .records, xpReward: 200, rarity: .rare
        ),
        AchievementDefinition(
            id: "pr.workout_120min",
            title: "Two Hour Beast",
            description: "Complete a single workout lasting 2 hours.",
            icon: "bolt.circle.fill",
            category: .records, xpReward: 600, rarity: .epic
        ),
        AchievementDefinition(
            id: "pr.workout_180min",
            title: "Endurance Legend",
            description: "Complete a single workout lasting 3+ hours.",
            icon: "crown.fill",
            category: .records, xpReward: 1500, rarity: .legendary
        )
    ]
}
