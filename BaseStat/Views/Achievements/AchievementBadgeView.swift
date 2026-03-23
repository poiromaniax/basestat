import SwiftUI
import SwiftData

struct AchievementBadgeView: View {
    var definition: AchievementDefinition
    var isUnlocked: Bool
    var unlockedDate: Date?
    var size: CGFloat = 80

    @State private var pressed = false
    @State private var glowPulse = false
    private var isNew: Bool { GamificationEngine.shared.recentlyUnlockedIds.contains(definition.id) }

    var body: some View {
        VStack(spacing: BaseStatTheme.Spacing.xs) {
            badgeCircle
            Text(definition.title)
                .font(BaseStatTheme.Typography.small)
                .foregroundStyle(isUnlocked ? .primary : .tertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: size + 8)
        }
        .scaleEffect(pressed ? 0.93 : 1.0)
        .animation(.spring(duration: 0.2), value: pressed)
        .onAppear {
            if isNew { glowPulse = true }
        }
        .onChange(of: isNew) { _, newValue in
            if newValue { glowPulse = true }
        }
    }

    private var badgeCircle: some View {
        ZStack {
            if isUnlocked {
                // Glow (extra pulse when newly unlocked)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [definition.rarity.swiftUIColor.opacity(glowPulse ? 0.7 : 0.45), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.6
                        )
                    )
                    .frame(width: size + 20, height: size + 20)
                    .blur(radius: glowPulse ? 12 : 8)
                    .scaleEffect(glowPulse ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glowPulse)

                // Gradient badge
                Circle()
                    .fill(
                        LinearGradient(
                            colors: definition.rarity.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: definition.rarity.swiftUIColor.opacity(0.5), radius: 8)

                // Rarity ring
                Circle()
                    .stroke(definition.rarity.swiftUIColor.opacity(0.6), lineWidth: 1.5)
                    .frame(width: size, height: size)

                Image(systemName: definition.icon)
                    .font(.system(size: size * 0.38))
                    .foregroundStyle(.white)
            } else {
                // Locked state
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: size, height: size)
                    .glassEffect(in: Circle())

                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    .frame(width: size, height: size)

                Image(systemName: definition.icon)
                    .font(.system(size: size * 0.38))
                    .foregroundStyle(.tertiary)

                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.quaternary)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 20, height: 20)
                    )
                    .offset(x: size * 0.3, y: size * 0.3)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Detailed Badge Sheet

struct AchievementDetailSheet: View {
    @Environment(\.modelContext) private var context
    var definition: AchievementDefinition
    var isUnlocked: Bool
    var unlockedDate: Date?

    var body: some View {
        ZStack {
            StaticMeshBackground(colors: BaseStatTheme.achievementMeshColors)

            ScrollView {
                VStack(spacing: BaseStatTheme.Spacing.lg) {
                    AchievementBadgeView(definition: definition, isUnlocked: isUnlocked, unlockedDate: unlockedDate, size: 110)

                    VStack(spacing: BaseStatTheme.Spacing.sm) {
                        Text(definition.title)
                            .font(BaseStatTheme.Typography.title2)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(definition.description)
                            .font(BaseStatTheme.Typography.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 12) {
                            rarityBadge
                            xpBadge
                        }

                        if isUnlocked, let date = unlockedDate {
                            Text("Unlocked \(date.shortDate)")
                                .font(BaseStatTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        } else {
                            Text("Not yet unlocked")
                                .font(BaseStatTheme.Typography.caption)
                                .foregroundStyle(.tertiary)
                                .padding(.top, 2)
                        }
                    }

                    if isUnlocked, let detail = earnedContext {
                        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.xs) {
                                Label("How you earned it", systemImage: "checkmark.seal.fill")
                                    .font(BaseStatTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                                    .tracking(1)
                                Text(detail)
                                    .font(BaseStatTheme.Typography.bodySemibold)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal, BaseStatTheme.Spacing.lg)
                    }

                    Spacer(minLength: BaseStatTheme.Spacing.xxl)
                }
                .padding(.top, BaseStatTheme.Spacing.xxl)
                .padding(.horizontal, BaseStatTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Earned Context

    private var earnedContext: String? {
        let snapshots = (try? context.fetch(
            FetchDescriptor<HealthSnapshot>(sortBy: [SortDescriptor(\.date)])
        )) ?? []
        let streaks = (try? context.fetch(FetchDescriptor<Streak>())) ?? []
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first
        let startWeight = UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.startingWeightKg)

        switch definition.id {
        case "weight.first_weigh_in":
            if let w = snapshots.compactMap(\.weightKg).first {
                return "First weight logged: \(w.asWeightString) kg"
            }
        case "weight.lost_1kg", "weight.lost_5kg", "weight.lost_10kg", "weight.lost_25kg":
            if startWeight > 0, let cur = snapshots.last(where: { $0.weightKg != nil })?.weightKg {
                return "From \(startWeight.asWeightString) → \(cur.asWeightString) kg · Lost \((startWeight - cur).formatted(decimals: 1)) kg"
            }
        case "weight.goal_reached":
            if let goal = profile?.weightGoalKg, let cur = snapshots.last(where: { $0.weightKg != nil })?.weightKg {
                return "Goal: \(goal.asWeightString) kg · Reached \(cur.asWeightString) kg"
            }
        case "weight.consistent_7":
            let days = snapshots.filter { $0.weightKg != nil }.count
            return "Weight logged on \(days) days total"
        case "steps.first_10k":
            if let best = snapshots.max(by: { $0.steps < $1.steps }) {
                return "Best step day: \(best.steps.formattedSteps) steps on \(best.date.shortDate)"
            }
        case "steps.streak_7", "steps.streak_30":
            if let s = streaks.first(where: { $0.type == .steps }) {
                return "Steps streak: \(s.currentCount) days · Best ever: \(s.longestCount) days"
            }
        case "steps.week_70k":
            if let best = snapshots.max(by: { $0.steps < $1.steps }) {
                return "Best single day: \(best.steps.formattedSteps) steps on \(best.date.shortDate)"
            }
        case "steps.million":
            let total = snapshots.reduce(0) { $0 + $1.steps }
            return "Total steps accumulated: \(total.formattedSteps)"
        case "exercise.first_workout":
            if let first = snapshots.first(where: { $0.exerciseMinutes >= 20 }) {
                return "First workout recorded on \(first.date.shortDate)"
            }
        case "exercise.workouts_10", "exercise.workouts_50", "exercise.workouts_100":
            let count = snapshots.filter { $0.exerciseMinutes >= 20 }.count
            return "Total workout days recorded: \(count)"
        case "exercise.streak_7", "exercise.streak_30":
            if let s = streaks.first(where: { $0.type == .exercise }) {
                return "Exercise streak: \(s.currentCount) days · Best ever: \(s.longestCount) days"
            }
        case "exercise.active_1hour":
            if let best = snapshots.max(by: { $0.exerciseMinutes < $1.exerciseMinutes }) {
                return "Best day: \(best.exerciseMinutes) active minutes on \(best.date.shortDate)"
            }
        case "sleep.first_8hours":
            if let best = snapshots.max(by: { $0.sleepHours < $1.sleepHours }) {
                return "Best sleep: \(best.sleepHours.formatted(decimals: 1)) hours on \(best.date.shortDate)"
            }
        case "sleep.streak_7", "sleep.streak_30":
            if let s = streaks.first(where: { $0.type == .sleep }) {
                return "Sleep streak: \(s.currentCount) days · Best ever: \(s.longestCount) days"
            }
        case "heart.first_reading":
            if let hr = snapshots.compactMap(\.heartRateResting).first {
                return "First resting HR reading: \(Int(hr)) bpm"
            }
        case "heart.resting_below_60":
            if let best = snapshots.compactMap(\.heartRateResting).min() {
                return "Best resting heart rate: \(Int(best)) bpm"
            }
        case "heart.improved_hr":
            let hrs = snapshots.compactMap(\.heartRateResting)
            if let first = hrs.first, let last = hrs.last {
                return "Heart rate: \(Int(first)) bpm → \(Int(last)) bpm"
            }
        case "meta.first_login":
            if let date = unlockedDate {
                return "Journey started on \(date.shortDate)"
            }
        case "meta.level_10", "meta.level_25", "meta.level_50":
            if let p = profile {
                return "Level \(p.level) · \(p.totalXP.asXPString) total XP earned"
            }
        case "meta.streak_7", "meta.streak_30", "meta.streak_100":
            if let s = streaks.first(where: { $0.type == .dailyLogin }) {
                return "Daily streak: \(s.currentCount) days · Best ever: \(s.longestCount) days"
            }
        case "pr.lowest_weight":
            if let min = snapshots.compactMap(\.weightKg).min() {
                return "All-time lowest weight: \(min.asWeightString) kg"
            }
        case "pr.steps_20k", "pr.steps_30k", "pr.steps_50k":
            if let best = snapshots.max(by: { $0.steps < $1.steps }) {
                return "Personal record: \(best.steps.formattedSteps) steps on \(best.date.shortDate)"
            }
        case "pr.calories_1000", "pr.calories_2000":
            if let best = snapshots.max(by: { $0.activeCalories < $1.activeCalories }) {
                return "Personal record: \(best.activeCalories.asCaloriesString) kcal on \(best.date.shortDate)"
            }
        case "pr.workout_60min", "pr.workout_120min", "pr.workout_180min":
            if let best = snapshots.max(by: { $0.exerciseMinutes < $1.exerciseMinutes }) {
                return "Best workout: \(best.exerciseMinutes) min on \(best.date.shortDate)"
            }
        default:
            return nil
        }
        return nil
    }

    // MARK: - Badges

    private var rarityBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(definition.rarity.swiftUIColor)
                .frame(width: 8, height: 8)
            Text(definition.rarity.rawValue)
                .font(BaseStatTheme.Typography.caption)
                .foregroundStyle(definition.rarity.swiftUIColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(definition.rarity.swiftUIColor.opacity(0.12))
        )
    }

    private var xpBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 11))
            Text(definition.xpReward.asXPString)
                .font(BaseStatTheme.Typography.xpLabel)
        }
        .foregroundStyle(BaseStatTheme.xpColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(BaseStatTheme.xpColor.opacity(0.12)))
    }
}

#Preview {
    HStack(spacing: 20) {
        AchievementBadgeView(
            definition: AchievementCatalog.all[4],
            isUnlocked: true,
            unlockedDate: Date()
        )
        AchievementBadgeView(
            definition: AchievementCatalog.all[5],
            isUnlocked: false
        )
    }
    .padding()
    .background(Color.black)
}
