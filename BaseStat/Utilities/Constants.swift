import Foundation

enum Constants {
    enum App {
        static let name             = "BaseStat"
        static let bundleId         = "com.basestat.app"
        static let iCloudContainer  = "iCloud.com.basestat.app"
        static let version          = "1.0.0"
    }

    enum Health {
        static let dailyStepsGoal: Int        = 10_000
        static let dailyExerciseMinutesGoal   = 30
        static let dailySleepHoursGoal        = 7.5
        static let dailyActiveCaloriesGoal    = 500.0
        static let heightCm: Double           = 170.0
    }

    enum Gamification {
        static let xpPerLevel: Int = 500
        static let maxLevel: Int = 100
    }

    enum Notifications {
        static let streakReminderHour   = 20
        static let streakReminderMinute = 0
        static let streakReminderCategoryId = "STREAK_REMINDER"
        static let achievementCategoryId    = "ACHIEVEMENT_UNLOCKED"
        static let challengeCategoryId      = "CHALLENGE_DEADLINE"
    }

    enum UserDefaultsKeys {
        static let onboardingComplete     = "onboardingComplete"
        static let lastHealthSyncDate     = "lastHealthSyncDate"
        static let startingWeightKg       = "startingWeightKg"
    }
}
