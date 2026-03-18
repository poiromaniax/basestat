import Foundation
import SwiftData

@Model
final class Achievement {
    var definitionId: String = ""
    var unlockedDate: Date?
    var isUnlocked: Bool = false

    init(definitionId: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.definitionId = definitionId
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }

    var definition: AchievementDefinition? {
        AchievementCatalog.all.first { $0.id == definitionId }
    }
}

// MARK: - Achievement Definition (static catalog entry)

struct AchievementDefinition: Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let xpReward: Int
    let rarity: AchievementRarity
}

enum AchievementCategory: String, CaseIterable, Sendable {
    case weight   = "Weight"
    case steps    = "Steps"
    case exercise = "Exercise"
    case sleep    = "Sleep"
    case heart    = "Heart"
    case meta     = "Milestones"

    var icon: String {
        switch self {
        case .weight:   return "scalemass.fill"
        case .steps:    return "figure.walk"
        case .exercise: return "flame.fill"
        case .sleep:    return "moon.zzz.fill"
        case .heart:    return "heart.fill"
        case .meta:     return "star.fill"
        }
    }
}

enum AchievementRarity: String, Sendable {
    case common    = "Common"
    case rare      = "Rare"
    case epic      = "Epic"
    case legendary = "Legendary"

    var color: String {
        switch self {
        case .common:    return "achievementCommon"
        case .rare:      return "achievementRare"
        case .epic:      return "achievementEpic"
        case .legendary: return "achievementLegendary"
        }
    }
}
