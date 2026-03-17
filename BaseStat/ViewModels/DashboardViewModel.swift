import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class DashboardViewModel {

    var isLoading: Bool = false
    var todaySnapshot: HealthSnapshot?
    var profile: UserProfile?
    var activeStreaks: [Streak] = []
    var activeChallenges: [Challenge] = []
    var recentActivity: [ActivityLog] = []

    private let healthKit = HealthKitManager.shared
    private let engine    = GamificationEngine.shared

    // MARK: - Load

    func load(context: ModelContext) async {
        await MainActor.run { isLoading = true }

        profile = engine.fetchOrCreateProfile(context: context)
        engine.ensureAllAchievementsExist(context: context)

        let snapshot = await healthKit.buildTodaySnapshot()
        let existing = fetchTodaySnapshot(context: context)

        if let existingSnap = existing {
            applySnapshot(snapshot, to: existingSnap)
            todaySnapshot = existingSnap
        } else {
            context.insert(snapshot)
            todaySnapshot = snapshot
        }

        engine.processSnapshot(snapshot, context: context)

        loadStreaks(context: context)
        loadActiveChallenges(context: context)
        loadRecentActivity(context: context)
        profile = engine.fetchOrCreateProfile(context: context)

        await MainActor.run { isLoading = false }
    }

    // MARK: - Helpers

    private func fetchTodaySnapshot(context: ModelContext) -> HealthSnapshot? {
        let start = Calendar.current.startOfDay(for: Date())
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? Date()
        let descriptor = FetchDescriptor<HealthSnapshot>(predicate: #Predicate { $0.date >= start && $0.date < end })
        return (try? context.fetch(descriptor))?.first
    }

    private func applySnapshot(_ source: HealthSnapshot, to target: HealthSnapshot) {
        target.weightKg           = source.weightKg ?? target.weightKg
        target.steps              = source.steps
        target.activeCalories     = source.activeCalories
        target.basalCalories      = source.basalCalories
        target.exerciseMinutes    = source.exerciseMinutes
        target.heartRateResting   = source.heartRateResting ?? target.heartRateResting
        target.heartRateAverage   = source.heartRateAverage ?? target.heartRateAverage
        target.sleepHours         = source.sleepHours
        target.dietaryCalories    = source.dietaryCalories
        target.distanceKm         = source.distanceKm
    }

    private func loadStreaks(context: ModelContext) {
        let descriptor = FetchDescriptor<Streak>()
        let all = (try? context.fetch(descriptor)) ?? []
        activeStreaks = all.filter { $0.currentCount > 0 }.sorted { $0.currentCount > $1.currentCount }
    }

    private func loadActiveChallenges(context: ModelContext) {
        let descriptor = FetchDescriptor<Challenge>(predicate: #Predicate { $0.isActive && !$0.isCompleted })
        activeChallenges = (try? context.fetch(descriptor)) ?? []
    }

    private func loadRecentActivity(context: ModelContext) {
        var descriptor = FetchDescriptor<ActivityLog>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = 10
        recentActivity = (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Display Helpers

    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Hey"
        }
    }

    var dailyXPEarned: Int {
        let start = Calendar.current.startOfDay(for: Date())
        return recentActivity
            .filter { $0.timestamp >= start }
            .reduce(0) { $0 + $1.xpEarned }
    }
}
