import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class GamificationEngine {

    static let shared = GamificationEngine()

    // MARK: - State
    var pendingLevelUp: Int?
    var pendingAchievements: [AchievementDefinition] = []
    var recentXPEvents: [(amount: Int, label: String)] = []

    /// When true, unlockAchievement tallies into batchUnlockedCount instead of showing popups
    var suppressPopups: Bool = false
    var batchUnlockedCount: Int = 0
    /// IDs of achievements unlocked in the current session — used for glow animation in gallery
    var recentlyUnlockedIds: Set<String> = []

    // MARK: - XP Awarding

    @discardableResult
    func awardXP(_ xpAmount: Int, reason: ActivityType, description: String, context: ModelContext) -> Int {
        let profile = fetchOrCreateProfile(context: context)
        let oldLevel = profile.level
        profile.totalXP += xpAmount

        let newLevel = computeLevel(for: profile.totalXP)
        profile.level = newLevel

        let log = ActivityLog(type: reason, xpEarned: xpAmount, eventDescription: description)
        context.insert(log)

        if newLevel > oldLevel {
            pendingLevelUp = newLevel
        }

        recentXPEvents.append((xpAmount, description))
        if recentXPEvents.count > 20 { recentXPEvents.removeFirst() }

        try? context.save()
        return xpAmount
    }

    private func computeLevel(for xp: Int) -> Int {
        var level = 1
        var threshold = 0
        while true {
            let next = threshold + level * Constants.Gamification.xpPerLevel
            if xp < next { break }
            threshold = next
            level += 1
            if level >= Constants.Gamification.maxLevel { break }
        }
        return level
    }

    // MARK: - Daily Processing

    func processSnapshot(_ snapshot: HealthSnapshot, context: ModelContext) {
        let profile = fetchOrCreateProfile(context: context)
        _ = profile

        // Steps goal
        if snapshot.steps >= Constants.Health.dailyStepsGoal {
            awardXP(BaseStatTheme.XPRewards.stepsGoal, reason: .stepsGoalHit, description: "Hit daily steps goal", context: context)
            updateStreak(type: .steps, context: context)
        }

        // Exercise goal
        if snapshot.exerciseMinutes >= Constants.Health.dailyExerciseMinutesGoal {
            awardXP(BaseStatTheme.XPRewards.workout, reason: .workoutCompleted, description: "Hit exercise goal", context: context)
            updateStreak(type: .exercise, context: context)
        }

        // Sleep goal
        if snapshot.sleepHours >= Constants.Health.dailySleepHoursGoal {
            awardXP(BaseStatTheme.XPRewards.sleepGoal, reason: .sleepGoalHit, description: "Hit sleep goal", context: context)
            updateStreak(type: .sleep, context: context)
        }

        // Calorie burn goal
        if snapshot.activeCalories >= Constants.Health.dailyActiveCaloriesGoal {
            awardXP(BaseStatTheme.XPRewards.calorieGoal, reason: .calorieGoalHit, description: "Hit calorie burn goal", context: context)
        }

        // Daily login — once per calendar day only
        let today = Calendar.current.startOfDay(for: Date())
        let lastLogin = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.lastDailyLoginDate) as? Date
        if lastLogin == nil || Calendar.current.startOfDay(for: lastLogin!) < today {
            awardXP(BaseStatTheme.XPRewards.dailyLogin, reason: .stepsGoalHit, description: "Daily login", context: context)
            updateStreak(type: .dailyLogin, context: context)
            UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.lastDailyLoginDate)
        }

        // Weight logged
        if snapshot.weightKg != nil {
            awardXP(BaseStatTheme.XPRewards.weightLog, reason: .weightLogged, description: "Logged weight", context: context)
            updateStreak(type: .weightLogging, context: context)
        }

        checkAchievements(snapshot: snapshot, context: context)
        updateChallenges(snapshot: snapshot, context: context)
    }

    // MARK: - Streaks

    func updateStreak(type: StreakType, context: ModelContext) {
        let descriptor = FetchDescriptor<Streak>()
        let streaks = (try? context.fetch(descriptor)) ?? []
        let streak = streaks.first(where: { $0.type == type }) ?? {
            let newStreak = Streak(type: type)
            context.insert(newStreak)
            return newStreak
        }()

        let wasActive = streak.isActiveToday
        streak.increment()

        if !wasActive {
            let milestones = [7, 14, 30, 60, 100]
            if milestones.contains(streak.currentCount) {
                awardXP(streak.currentCount * 10, reason: .streakMilestone,
                        description: "\(type.rawValue) \(streak.currentCount)-day streak!", context: context)
            }
        }
        try? context.save()
    }

    func fetchStreak(type: StreakType, context: ModelContext) -> Streak {
        let descriptor = FetchDescriptor<Streak>()
        let streaks = (try? context.fetch(descriptor)) ?? []
        return streaks.first(where: { $0.type == type }) ?? Streak(type: type)
    }

    // MARK: - Achievements

    func checkAchievements(snapshot: HealthSnapshot, context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let unlockedIds = Set(existing.filter(\.isUnlocked).map(\.definitionId))
        let profile = fetchOrCreateProfile(context: context)

        var toUnlock: [AchievementDefinition] = []

        for def in AchievementCatalog.all {
            guard !unlockedIds.contains(def.id) else { continue }
            if shouldUnlock(def, snapshot: snapshot, profile: profile, context: context) {
                toUnlock.append(def)
            }
        }

        for def in toUnlock {
            unlockAchievement(def, context: context)
        }
    }

    private func shouldUnlock(
        _ def: AchievementDefinition,
        snapshot: HealthSnapshot,
        profile: UserProfile,
        context: ModelContext
    ) -> Bool {
        let startWeight = UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.startingWeightKg)
        if def.id.hasPrefix("weight.") {
            return shouldUnlockWeight(def, snapshot: snapshot, profile: profile, startWeight: startWeight, context: context)
        } else if def.id.hasPrefix("steps.") {
            return shouldUnlockSteps(def, snapshot: snapshot, context: context)
        } else if def.id.hasPrefix("exercise.") {
            return shouldUnlockExercise(def, snapshot: snapshot, context: context)
        } else if def.id.hasPrefix("sleep.") {
            return shouldUnlockSleep(def, snapshot: snapshot, context: context)
        } else if def.id.hasPrefix("heart.") {
            return shouldUnlockHeart(def, snapshot: snapshot)
        } else if def.id.hasPrefix("meta.") {
            return shouldUnlockMeta(def, profile: profile, context: context)
        }
        return false
    }

    private func shouldUnlockWeight(
        _ def: AchievementDefinition, snapshot: HealthSnapshot,
        profile: UserProfile, startWeight: Double, context: ModelContext
    ) -> Bool {
        let history = fetchWeightHistory(context: context)
        switch def.id {
        case "weight.first_weigh_in": return snapshot.weightKg != nil
        case "weight.lost_1kg":
            guard let cur = snapshot.weightKg, startWeight > 0 else { return false }
            return (startWeight - cur) >= 1
        case "weight.lost_5kg":
            guard let cur = snapshot.weightKg, startWeight > 0 else { return false }
            return (startWeight - cur) >= 5
        case "weight.lost_10kg":
            guard let cur = snapshot.weightKg, startWeight > 0 else { return false }
            return (startWeight - cur) >= 10
        case "weight.lost_25kg":
            guard let cur = snapshot.weightKg, startWeight > 0 else { return false }
            return (startWeight - cur) >= 25
        case "weight.goal_reached":
            guard let cur = snapshot.weightKg else { return false }
            return cur <= profile.weightGoalKg
        case "weight.consistent_7": return history.count >= 7
        default: return false
        }
    }

    private func shouldUnlockSteps(
        _ def: AchievementDefinition, snapshot: HealthSnapshot, context: ModelContext
    ) -> Bool {
        switch def.id {
        case "steps.first_10k": return snapshot.steps >= 10_000
        case "steps.week_70k": return totalStepsLastDays(7, context: context) >= 70_000
        case "steps.streak_7": return fetchStreak(type: .steps, context: context).currentCount >= 7
        case "steps.streak_30": return fetchStreak(type: .steps, context: context).currentCount >= 30
        case "steps.million":
            let all = (try? context.fetch(FetchDescriptor<HealthSnapshot>())) ?? []
            return all.reduce(0) { $0 + $1.steps } >= 1_000_000
        default: return false
        }
    }

    private func shouldUnlockExercise(
        _ def: AchievementDefinition, snapshot: HealthSnapshot, context: ModelContext
    ) -> Bool {
        switch def.id {
        case "exercise.first_workout": return snapshot.exerciseMinutes >= 30
        case "exercise.active_1hour": return snapshot.exerciseMinutes >= 60
        case "exercise.workouts_10": return totalWorkoutDays(context: context) >= 10
        case "exercise.workouts_50": return totalWorkoutDays(context: context) >= 50
        case "exercise.workouts_100": return totalWorkoutDays(context: context) >= 100
        case "exercise.streak_7": return fetchStreak(type: .exercise, context: context).currentCount >= 7
        case "exercise.streak_30": return fetchStreak(type: .exercise, context: context).currentCount >= 30
        default: return false
        }
    }

    private func shouldUnlockSleep(
        _ def: AchievementDefinition, snapshot: HealthSnapshot, context: ModelContext
    ) -> Bool {
        switch def.id {
        case "sleep.first_8hours": return snapshot.sleepHours >= 8
        case "sleep.streak_7": return fetchStreak(type: .sleep, context: context).currentCount >= 7
        case "sleep.streak_30": return fetchStreak(type: .sleep, context: context).currentCount >= 30
        default: return false
        }
    }

    private func shouldUnlockHeart(_ def: AchievementDefinition, snapshot: HealthSnapshot) -> Bool {
        switch def.id {
        case "heart.first_reading": return snapshot.heartRateResting != nil
        case "heart.resting_below_60": return (snapshot.heartRateResting ?? 999) < 60
        default: return false
        }
    }

    private func shouldUnlockMeta(
        _ def: AchievementDefinition, profile: UserProfile, context: ModelContext
    ) -> Bool {
        switch def.id {
        case "meta.first_login": return true
        case "meta.level_10": return profile.level >= 10
        case "meta.level_25": return profile.level >= 25
        case "meta.level_50": return profile.level >= 50
        case "meta.streak_7": return fetchStreak(type: .dailyLogin, context: context).currentCount >= 7
        case "meta.streak_30": return fetchStreak(type: .dailyLogin, context: context).currentCount >= 30
        case "meta.streak_100": return fetchStreak(type: .dailyLogin, context: context).currentCount >= 100
        default: return false
        }
    }

    func unlockAchievement(_ def: AchievementDefinition, context: ModelContext) {
        let defId = def.id
        let descriptor = FetchDescriptor<Achievement>(predicate: #Predicate { $0.definitionId == defId })
        if let existing = (try? context.fetch(descriptor))?.first {
            if !existing.isUnlocked {
                existing.isUnlocked = true
                existing.unlockedDate = Date()
            }
        } else {
            let ach = Achievement(definitionId: def.id, isUnlocked: true, unlockedDate: Date())
            context.insert(ach)
        }
        awardXP(def.xpReward, reason: .achievementUnlocked, description: "Unlocked: \(def.title)", context: context)
        recentlyUnlockedIds.insert(def.id)
        if suppressPopups {
            batchUnlockedCount += 1
        } else {
            pendingAchievements.append(def)
        }
        try? context.save()
    }

    func ensureAllAchievementsExist(context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        let existing = Set((try? context.fetch(descriptor))?.map(\.definitionId) ?? [])
        for def in AchievementCatalog.all where !existing.contains(def.id) {
            context.insert(Achievement(definitionId: def.id))
        }
        try? context.save()
    }

    // MARK: - Challenges

    func updateChallenges(snapshot: HealthSnapshot, context: ModelContext) {
        let descriptor = FetchDescriptor<Challenge>(predicate: #Predicate { $0.isActive && !$0.isCompleted })
        let challenges = (try? context.fetch(descriptor)) ?? []

        for challenge in challenges {
            switch challenge.metric {
            case .steps:
                challenge.currentValue += Double(snapshot.steps)
            case .activeCalories:
                challenge.currentValue += snapshot.activeCalories
            case .exerciseMinutes:
                challenge.currentValue += Double(snapshot.exerciseMinutes)
            case .weightLoss:
                let start = UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.startingWeightKg)
                if let current = snapshot.weightKg, start > 0 {
                    challenge.currentValue = max(0, start - current)
                }
            case .sleepHours:
                challenge.currentValue += snapshot.sleepHours
            case .workouts:
                if snapshot.exerciseMinutes >= 20 {
                    challenge.currentValue += 1
                }
            }

            if challenge.currentValue >= challenge.targetValue {
                challenge.isCompleted = true
                awardXP(challenge.xpReward, reason: .challengeCompleted, description: "Completed: \(challenge.title)", context: context)
            }

            if challenge.isExpired {
                challenge.isActive = false
            }
        }
        try? context.save()
    }

    // MARK: - Personal Records

    func checkPersonalRecords(context: ModelContext) async {
        let prs = await HealthKitManager.shared.fetchPersonalRecords()
        let unlockedIds = Set(
            ((try? context.fetch(FetchDescriptor<Achievement>())) ?? [])
                .filter(\.isUnlocked).map(\.definitionId)
        )
        var candidates: [String] = []
        if prs.lowestWeightKg != nil { candidates.append("pr.lowest_weight") }
        if prs.mostStepsInDay >= 20_000 { candidates.append("pr.steps_20k") }
        if prs.mostStepsInDay >= 30_000 { candidates.append("pr.steps_30k") }
        if prs.mostStepsInDay >= 50_000 { candidates.append("pr.steps_50k") }
        if prs.mostActiveCaloriesInDay >= 1_000 { candidates.append("pr.calories_1000") }
        if prs.mostActiveCaloriesInDay >= 2_000 { candidates.append("pr.calories_2000") }
        if prs.longestWorkoutMinutes >= 60 { candidates.append("pr.workout_60min") }
        if prs.longestWorkoutMinutes >= 120 { candidates.append("pr.workout_120min") }
        if prs.longestWorkoutMinutes >= 180 { candidates.append("pr.workout_180min") }
        for id in candidates where !unlockedIds.contains(id) {
            if let def = AchievementCatalog.all.first(where: { $0.id == id }) {
                unlockAchievement(def, context: context)
            }
        }
    }

    // MARK: - Profile

    func fetchOrCreateProfile(context: ModelContext) -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let profile = (try? context.fetch(descriptor))?.first {
            return profile
        }
        let profile = UserProfile()
        context.insert(profile)
        try? context.save()
        return profile
    }

    // MARK: - Helpers

    private func fetchWeightHistory(context: ModelContext) -> [HealthSnapshot] {
        let descriptor = FetchDescriptor<HealthSnapshot>()
        return ((try? context.fetch(descriptor)) ?? []).filter { $0.weightKg != nil }
    }

    private func totalStepsLastDays(_ days: Int, context: ModelContext) -> Int {
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<HealthSnapshot>(predicate: #Predicate { $0.date >= start })
        let snapshots = (try? context.fetch(descriptor)) ?? []
        return snapshots.reduce(0) { $0 + $1.steps }
    }

    private func totalWorkoutDays(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<HealthSnapshot>(predicate: #Predicate { $0.exerciseMinutes >= 20 })
        return (try? context.fetch(descriptor))?.count ?? 0
    }
}
