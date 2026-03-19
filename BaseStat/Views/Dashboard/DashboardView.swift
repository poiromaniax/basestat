import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = DashboardViewModel()
    @State private var engine    = GamificationEngine.shared
    @State private var showBatchBanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                GradientMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

                ScrollView {
                    LazyVStack(spacing: BaseStatTheme.Spacing.md) {
                        scrollableHeader
                        heroSection
                        xpSection
                        metricsGrid
                        streaksSection
                        challengesSection
                        recentActivitySection
                    }
                    .padding(.horizontal, BaseStatTheme.Spacing.md)
                    .padding(.top, BaseStatTheme.Spacing.md)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
                }
            }
            .navigationBarHidden(true)
            .overlay { overlays }
            .task { await viewModel.load(context: context) }
            .refreshable { await viewModel.load(context: context) }
            .onChange(of: engine.batchUnlockedCount) { _, count in
                if count > 0 { withAnimation { showBatchBanner = true } }
            }
        }
    }

    // MARK: - Sections

    private var scrollableHeader: some View {
        HStack {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            Spacer()
        }
        .padding(.top, BaseStatTheme.Spacing.sm)
    }

    private var heroSection: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.lg) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.xs) {
                    let nameStr = viewModel.profile?.name.isEmpty == false ? ", \(viewModel.profile!.name)" : ""
                    Text(viewModel.greetingMessage + nameStr)
                        .font(BaseStatTheme.Typography.title3)
                        .foregroundStyle(.secondary)
                    Text("Day \(daysSinceJoin) of your journey")
                        .font(BaseStatTheme.Typography.title1)
                        .foregroundStyle(.primary)
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(BaseStatTheme.xpColor)
                        Text("+\(viewModel.dailyXPEarned) XP today")
                            .xpLabelStyle()
                    }
                }
                Spacer()
                if let profile = viewModel.profile {
                    LevelProgressRing(profile: profile, size: 80)
                }
            }
        }
    }

    private var xpSection: some View {
        Group {
            if let profile = viewModel.profile {
                GlassCard(cornerRadius: BaseStatTheme.Radius.md, padding: BaseStatTheme.Spacing.md) {
                    XPProgressBar(profile: profile)
                }
            }
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BaseStatTheme.Spacing.sm) {
            if let snap = viewModel.todaySnapshot {
                MetricCardView(
                    title: "Steps",
                    value: snap.steps.formattedSteps,
                    unit: "steps",
                    icon: "figure.walk",
                    color: BaseStatTheme.primaryTeal,
                    progress: snap.stepsGoalProgress
                )
                MetricCardView(
                    title: "Active Cal",
                    value: snap.activeCalories.asCaloriesString,
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange,
                    progress: min(1, snap.activeCalories / Constants.Health.dailyActiveCaloriesGoal)
                )
                MetricCardView(
                    title: "Exercise",
                    value: "\(snap.exerciseMinutes)",
                    unit: "min",
                    icon: "timer",
                    color: .green,
                    progress: snap.exerciseGoalProgress
                )
                MetricCardView(
                    title: "Sleep",
                    value: snap.sleepHours.formatted(decimals: 1),
                    unit: "hrs",
                    icon: "moon.zzz.fill",
                    color: .indigo,
                    progress: snap.sleepGoalProgress
                )
                if let bpm = snap.heartRateResting {
                    MetricCardView(
                        title: "Resting HR",
                        value: "\(Int(bpm))",
                        unit: "bpm",
                        icon: "heart.fill",
                        color: .red
                    )
                }
                if let weightKg = snap.weightKg {
                    MetricCardView(
                        title: "Weight",
                        value: weightKg.asWeightString,
                        unit: "kg",
                        icon: "scalemass.fill",
                        color: .cyan
                    )
                }
            } else {
                placeholderMetrics
            }
        }
    }

    private var placeholderMetrics: some View {
        ForEach(0..<4, id: \.self) { _ in
            RoundedRectangle(cornerRadius: BaseStatTheme.Radius.md)
                .fill(Color.white.opacity(0.05))
                .frame(height: 90)
                .glassEffect(in: RoundedRectangle(cornerRadius: BaseStatTheme.Radius.md))
                .redacted(reason: .placeholder)
        }
    }

    private var streaksSection: some View {
        Group {
            if !viewModel.activeStreaks.isEmpty {
                GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                    VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                        Text("Active Streaks")
                            .sectionHeaderStyle()

                        ForEach(viewModel.activeStreaks.prefix(3), id: \.type) { streak in
                            StreakBadge(streak: streak)
                            if streak.type != viewModel.activeStreaks.prefix(3).last?.type {
                                Divider().opacity(0.2)
                            }
                        }
                    }
                }
            }
        }
    }

    private var challengesSection: some View {
        Group {
            if !viewModel.activeChallenges.isEmpty {
                VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                    Text("Active Challenges")
                        .sectionHeaderStyle()
                        .padding(.leading, BaseStatTheme.Spacing.xs)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: BaseStatTheme.Spacing.sm) {
                            ForEach(viewModel.activeChallenges, id: \.id) { challenge in
                                MiniChallengeCard(challenge: challenge)
                            }
                        }
                    }
                }
            }
        }
    }

    private var recentActivitySection: some View {
        Group {
            if !viewModel.recentActivity.isEmpty {
                GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                    VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                        Text("Recent Activity")
                            .sectionHeaderStyle()

                        ForEach(viewModel.recentActivity.prefix(5), id: \.id) { log in
                            HStack(spacing: 10) {
                                Image(systemName: log.type.icon)
                                    .font(.system(size: 13))
                                    .foregroundStyle(BaseStatTheme.xpColor)
                                    .frame(width: 20)
                                Text(log.eventDescription)
                                    .font(BaseStatTheme.Typography.body)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(log.xpEarned.asXPString)
                                    .xpLabelStyle()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Overlays

    @ViewBuilder
    private var overlays: some View {
        if let level = engine.pendingLevelUp {
            LevelUpOverlay(newLevel: level) {
                engine.pendingLevelUp = nil
            }
            .transition(.opacity)
            .zIndex(10)
        } else if let achievement = engine.pendingAchievements.first {
            BadgeUnlockOverlay(
                achievement: achievement,
                hasMore: engine.pendingAchievements.count > 1
            ) {
                engine.pendingAchievements.removeFirst()
            }
            .id(achievement.id)
            .transition(.opacity)
            .zIndex(9)
        } else if showBatchBanner, engine.batchUnlockedCount > 0 {
            batchUnlockBanner
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(8)
        }
    }

    // MARK: - Batch Unlock Banner

    private var batchUnlockBanner: some View {
        VStack {
            HStack(spacing: BaseStatTheme.Spacing.sm) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(BaseStatTheme.rarityLegendary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(engine.batchUnlockedCount) achievements unlocked!")
                        .font(BaseStatTheme.Typography.bodySemibold)
                    Text("Visit the Achievements tab to see your badges")
                        .font(BaseStatTheme.Typography.small)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    withAnimation { showBatchBanner = false }
                    engine.batchUnlockedCount = 0
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(BaseStatTheme.Spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BaseStatTheme.Radius.md))
            .padding(.horizontal, BaseStatTheme.Spacing.md)
            .padding(.top, 56)
            Spacer()
        }
    }

    // MARK: - Helpers

    private var daysSinceJoin: Int {
        let startDate: Date
        if let saved = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.journeyStartDate) as? Date {
            startDate = saved
        } else {
            startDate = viewModel.profile?.joinDate ?? Date()
        }
        let cal = Calendar.current
        let elapsed = cal.dateComponents([.day], from: cal.startOfDay(for: startDate), to: cal.startOfDay(for: Date())).day ?? 0
        return elapsed + 1
    }
}

// MARK: - Mini Challenge Card

struct MiniChallengeCard: View {
    var challenge: Challenge

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.sm, padding: BaseStatTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: challenge.metric.icon)
                        .font(.system(size: 13))
                        .foregroundStyle(BaseStatTheme.primaryTeal)
                    Spacer()
                    Text(challenge.statusLabel)
                        .font(BaseStatTheme.Typography.small)
                        .foregroundStyle(.secondary)
                }
                Text(challenge.title)
                    .font(BaseStatTheme.Typography.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                ProgressBar(progress: challenge.progress, color: BaseStatTheme.primaryTeal, height: 4)
                Text("\(Int(challenge.progress * 100))%")
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140)
        }
    }
}
