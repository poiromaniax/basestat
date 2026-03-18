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
        static let healthHistoryDays      = "healthHistoryDays"
        static let lastDailyLoginDate     = "lastDailyLoginDate"
    }

    enum HistoryOption: Int, CaseIterable, Identifiable {
        case threeMonths  = 90
        case sixMonths    = 180
        case oneYear      = 365
        case twoYears     = 730

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .threeMonths: return "3 Months"
            case .sixMonths:   return "6 Months"
            case .oneYear:     return "1 Year"
            case .twoYears:    return "2 Years"
            }
        }

        var description: String {
            switch self {
            case .threeMonths: return "Quick start — recent data only"
            case .sixMonths:   return "Half a year of trends"
            case .oneYear:     return "Full year of insights"
            case .twoYears:    return "Deep history & personal records"
            }
        }

        static var saved: HistoryOption {
            let days = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.healthHistoryDays)
            return HistoryOption(rawValue: days) ?? .oneYear
        }
    }
}
