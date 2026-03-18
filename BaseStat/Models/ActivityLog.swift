import Foundation
import SwiftData

enum ActivityType: String, Codable {
    case weightLogged        = "Weight Logged"
    case stepsGoalHit        = "Steps Goal Hit"
    case workoutCompleted    = "Workout Completed"
    case achievementUnlocked = "Achievement Unlocked"
    case challengeCompleted  = "Challenge Completed"
    case levelUp             = "Level Up"
    case streakMilestone     = "Streak Milestone"
    case sleepGoalHit        = "Sleep Goal Hit"
    case calorieGoalHit      = "Calorie Goal Hit"

    var icon: String {
        switch self {
        case .weightLogged:        return "scalemass.fill"
        case .stepsGoalHit:        return "figure.walk"
        case .workoutCompleted:    return "dumbbell.fill"
        case .achievementUnlocked: return "star.fill"
        case .challengeCompleted:  return "flag.checkered.fill"
        case .levelUp:             return "arrow.up.circle.fill"
        case .streakMilestone:     return "flame.fill"
        case .sleepGoalHit:        return "moon.zzz.fill"
        case .calorieGoalHit:      return "flame.circle.fill"
        }
    }
}

@Model
final class ActivityLog {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var typeRawValue: String = ActivityType.weightLogged.rawValue
    var xpEarned: Int = 0
    var eventDescription: String = ""
    var relatedId: String?

    var type: ActivityType {
        get { ActivityType(rawValue: typeRawValue) ?? .weightLogged }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: ActivityType,
        xpEarned: Int,
        eventDescription: String,
        relatedId: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.typeRawValue = type.rawValue
        self.xpEarned = xpEarned
        self.eventDescription = eventDescription
        self.relatedId = relatedId
    }
}
