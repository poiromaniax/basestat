import Foundation
import SwiftData

enum ChallengeMetric: String, Codable, CaseIterable {
    case steps          = "Steps"
    case activeCalories = "Active Calories"
    case exerciseMinutes = "Exercise Minutes"
    case weightLoss     = "Weight Loss (kg)"
    case sleepHours     = "Sleep Hours"
    case workouts       = "Workouts"

    var unit: String {
        switch self {
        case .steps:           return "steps"
        case .activeCalories:  return "cal"
        case .exerciseMinutes: return "min"
        case .weightLoss:      return "kg"
        case .sleepHours:      return "hrs"
        case .workouts:        return "workouts"
        }
    }

    var icon: String {
        switch self {
        case .steps:           return "figure.walk"
        case .activeCalories:  return "flame.fill"
        case .exerciseMinutes: return "timer"
        case .weightLoss:      return "scalemass.fill"
        case .sleepHours:      return "moon.zzz.fill"
        case .workouts:        return "dumbbell.fill"
        }
    }
}

@Model
final class Challenge {
    var id: UUID = UUID()
    var title: String = ""
    var challengeDescription: String = ""
    var metricRawValue: String = ChallengeMetric.steps.rawValue
    var targetValue: Double = 0
    var currentValue: Double = 0
    var startDate: Date = Date()
    var endDate: Date = Date()
    var xpReward: Int = 0
    var isCompleted: Bool = false
    var isActive: Bool = true

    var metric: ChallengeMetric {
        get { ChallengeMetric(rawValue: metricRawValue) ?? .steps }
        set { metricRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        challengeDescription: String,
        metric: ChallengeMetric,
        targetValue: Double,
        currentValue: Double = 0,
        startDate: Date = Date(),
        endDate: Date,
        xpReward: Int,
        isCompleted: Bool = false,
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.challengeDescription = challengeDescription
        self.metricRawValue = metric.rawValue
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.startDate = startDate
        self.endDate = endDate
        self.xpReward = xpReward
        self.isCompleted = isCompleted
        self.isActive = isActive
    }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, currentValue / targetValue)
    }

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }

    var isExpired: Bool {
        Date() > endDate && !isCompleted
    }

    var statusLabel: String {
        if isCompleted { return "Completed" }
        if isExpired { return "Expired" }
        return "\(daysRemaining)d left"
    }
}

// MARK: - Preset challenge templates

struct ChallengeTemplate {
    let title: String
    let description: String
    let metric: ChallengeMetric
    let targetValue: Double
    let durationDays: Int
    let xpReward: Int

    func makeChallenge() -> Challenge {
        Challenge(
            title: title,
            challengeDescription: description,
            metric: metric,
            targetValue: targetValue,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: durationDays, to: Date()) ?? Date(),
            xpReward: xpReward
        )
    }
}

enum ChallengeTemplates {
    static let all: [ChallengeTemplate] = [
        ChallengeTemplate(
            title: "Step Master",
            description: "Walk 70,000 steps this week.",
            metric: .steps, targetValue: 70_000, durationDays: 7, xpReward: 400
        ),
        ChallengeTemplate(
            title: "Burn It Down",
            description: "Burn 3,500 active calories in 7 days.",
            metric: .activeCalories, targetValue: 3500, durationDays: 7, xpReward: 350
        ),
        ChallengeTemplate(
            title: "3-Week Warrior",
            description: "Complete 15 workouts in 21 days.",
            metric: .workouts, targetValue: 15, durationDays: 21, xpReward: 800
        ),
        ChallengeTemplate(
            title: "Sleep Restoration",
            description: "Get 56 hours of sleep in 7 days (avg 8hrs/night).",
            metric: .sleepHours, targetValue: 56, durationDays: 7, xpReward: 300
        ),
        ChallengeTemplate(
            title: "Lose 2 Kilos",
            description: "Lose 2 kg in the next 30 days.",
            metric: .weightLoss, targetValue: 2, durationDays: 30, xpReward: 600
        ),
        ChallengeTemplate(
            title: "Move Every Day",
            description: "Get 30+ exercise minutes every day for 2 weeks.",
            metric: .exerciseMinutes, targetValue: 420, durationDays: 14, xpReward: 700
        )
    ]
}
