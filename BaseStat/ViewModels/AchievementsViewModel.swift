import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class AchievementsViewModel {

    var achievements: [Achievement] = []
    var selectedCategory: AchievementCategory?
    var selectedAchievement: AchievementDefinition?
    var totalUnlocked: Int = 0
    var totalXPFromAchievements: Int = 0

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        achievements = (try? context.fetch(descriptor)) ?? []
        totalUnlocked = achievements.filter(\.isUnlocked).count
        totalXPFromAchievements = achievements
            .filter(\.isUnlocked)
            .compactMap { $0.definition?.xpReward }
            .reduce(0, +)
    }

    var filtered: [AchievementDefinition] {
        let all = AchievementCatalog.all
        guard let cat = selectedCategory else { return all }
        return all.filter { $0.category == cat }
    }

    func isUnlocked(_ id: String) -> Bool {
        achievements.first { $0.definitionId == id }?.isUnlocked ?? false
    }

    func unlockedDate(for id: String) -> Date? {
        achievements.first { $0.definitionId == id }?.unlockedDate
    }

    var completionPercent: Double {
        let total = AchievementCatalog.all.count
        guard total > 0 else { return 0 }
        return Double(totalUnlocked) / Double(total)
    }

    var unlockedByCategory: [AchievementCategory: Int] {
        var result: [AchievementCategory: Int] = [:]
        for cat in AchievementCategory.allCases {
            let ids = AchievementCatalog.all.filter { $0.category == cat }.map(\.id)
            result[cat] = achievements.filter { ids.contains($0.definitionId) && $0.isUnlocked }.count
        }
        return result
    }

    var totalByCategory: [AchievementCategory: Int] {
        var result: [AchievementCategory: Int] = [:]
        for cat in AchievementCategory.allCases {
            result[cat] = AchievementCatalog.all.filter { $0.category == cat }.count
        }
        return result
    }
}
