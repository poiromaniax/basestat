import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    var profile: UserProfile?
    var streaks: [Streak] = []
    var recentActivity: [ActivityLog] = []
    var totalAchievements: Int = 0
    var unlockedAchievements: Int = 0
    var totalWorkouts: Int = 0
    var weightLostKg: Double = 0

    func load(context: ModelContext) {
        let engine = GamificationEngine.shared
        profile = engine.fetchOrCreateProfile(context: context)

        let streakDescriptor = FetchDescriptor<Streak>()
        streaks = (try? context.fetch(streakDescriptor)) ?? []

        var activityDescriptor = FetchDescriptor<ActivityLog>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        activityDescriptor.fetchLimit = 20
        recentActivity = (try? context.fetch(activityDescriptor)) ?? []

        let achievementDescriptor = FetchDescriptor<Achievement>()
        let achievements = (try? context.fetch(achievementDescriptor)) ?? []
        totalAchievements    = AchievementCatalog.all.count
        unlockedAchievements = achievements.filter(\.isUnlocked).count

        let workoutDescriptor = FetchDescriptor<HealthSnapshot>(predicate: #Predicate { $0.exerciseMinutes >= 20 })
        totalWorkouts = (try? context.fetch(workoutDescriptor))?.count ?? 0

        let snapshotDescriptor = FetchDescriptor<HealthSnapshot>(sortBy: [SortDescriptor(\.date)])
        let snapshots = (try? context.fetch(snapshotDescriptor)) ?? []
        if let firstWeight = snapshots.compactMap(\.weightKg).first,
           let latestWeight = snapshots.compactMap(\.weightKg).last {
            weightLostKg = max(0, firstWeight - latestWeight)
        }
    }

    func updateProfile(name: String, weightGoal: Double, weightUnit: String, context: ModelContext) {
        guard let existing = profile else { return }
        existing.name = name
        existing.weightGoalKg = weightGoal
        existing.weightUnit = weightUnit
        try? context.save()
    }

    var longestStreak: Streak? {
        streaks.max { $0.longestCount < $1.longestCount }
    }

    var bestActiveStreak: Streak? {
        streaks.filter { $0.currentCount > 0 }.max { $0.currentCount < $1.currentCount }
    }
}
