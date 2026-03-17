import Foundation
import SwiftData

enum StreakType: String, Codable, CaseIterable {
    case dailyLogin    = "Daily Login"
    case steps         = "Steps"
    case exercise      = "Exercise"
    case weightLogging = "Weight Logging"
    case sleep         = "Sleep"

    var icon: String {
        switch self {
        case .dailyLogin:    return "app.badge.checkmark.fill"
        case .steps:         return "figure.walk"
        case .exercise:      return "flame.fill"
        case .weightLogging: return "scalemass.fill"
        case .sleep:         return "moon.zzz.fill"
        }
    }

    var color: String {
        switch self {
        case .dailyLogin:    return "streakMeta"
        case .steps:         return "streakSteps"
        case .exercise:      return "streakFire"
        case .weightLogging: return "streakWeight"
        case .sleep:         return "streakSleep"
        }
    }

    var goalDescription: String {
        switch self {
        case .dailyLogin:    return "Open BaseStat daily"
        case .steps:         return "Hit 10,000 steps"
        case .exercise:      return "Complete a workout"
        case .weightLogging: return "Log your weight"
        case .sleep:         return "Get 7+ hours of sleep"
        }
    }
}

@Model
final class Streak {
    var type: StreakType
    var currentCount: Int
    var longestCount: Int
    var lastActiveDate: Date?

    init(type: StreakType, currentCount: Int = 0, longestCount: Int = 0, lastActiveDate: Date? = nil) {
        self.type = type
        self.currentCount = currentCount
        self.longestCount = longestCount
        self.lastActiveDate = lastActiveDate
    }

    var isActiveToday: Bool {
        guard let last = lastActiveDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var isAtRisk: Bool {
        guard let last = lastActiveDate, currentCount > 0 else { return false }
        return !Calendar.current.isDateInToday(last) && Calendar.current.isDateInYesterday(last)
    }

    func increment() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastActiveDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                currentCount += 1
            } else if diff == 0 {
                return // Already counted today
            } else {
                currentCount = 1 // Streak broken
            }
        } else {
            currentCount = 1
        }
        lastActiveDate = Date()
        if currentCount > longestCount {
            longestCount = currentCount
        }
    }

    func reset() {
        currentCount = 0
    }
}
