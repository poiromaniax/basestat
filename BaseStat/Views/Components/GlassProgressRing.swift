import SwiftUI

struct GlassProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 10
    var size: CGFloat = 80
    var color: Color = BaseStatTheme.primaryTeal
    var trackColor: Color = Color.white.opacity(0.10)
    var label: String?

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: BaseStatTheme.Animation.normal), value: progress)

            if let label {
                Text(label)
                    .font(BaseStatTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - XP Level Ring

struct LevelProgressRing: View {
    var profile: UserProfile
    var size: CGFloat = 90

    var body: some View {
        ZStack {
            GlassProgressRing(
                progress: profile.levelProgress,
                lineWidth: 8,
                size: size,
                color: BaseStatTheme.xpColor
            )

            VStack(spacing: 2) {
                Text("\(profile.level)")
                    .font(BaseStatTheme.Typography.levelBadge)
                    .foregroundStyle(BaseStatTheme.xpColor)
                Text("LVL")
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Level Progression Sheet

struct LevelProgressionSheet: View {
    var profile: UserProfile

    var body: some View {
        ZStack {
            StaticMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

            VStack(spacing: 0) {
                headerSection
                Divider().opacity(0.2)
                levelList
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: BaseStatTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Level Progression")
                    .font(BaseStatTheme.Typography.title2)
                    .foregroundStyle(.primary)
                Text("\(profile.levelTitle) · \(profile.totalXP.asXPString) total XP")
                    .font(BaseStatTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            LevelProgressRing(profile: profile, size: 64)
        }
        .padding(BaseStatTheme.Spacing.lg)
    }

    private var levelList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(1...50, id: \.self) { lvl in
                        levelRow(lvl)
                            .id(lvl)
                        if lvl < 50 {
                            Divider().opacity(0.12).padding(.leading, 64)
                        }
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(max(1, profile.level - 2), anchor: .top)
            }
        }
    }

    private func levelRow(_ lvl: Int) -> some View {
        let isCurrent  = lvl == profile.level
        let isUnlocked = lvl < profile.level
        let xpNeeded   = xpThreshold(for: lvl)
        let nextXP     = xpThreshold(for: lvl + 1)

        return HStack(spacing: BaseStatTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(isCurrent ? BaseStatTheme.xpColor.opacity(0.25)
                          : (isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.03)))
                    .frame(width: 40, height: 40)
                Text("\(lvl)")
                    .font(BaseStatTheme.Typography.bodySemibold)
                    .foregroundStyle(isCurrent ? BaseStatTheme.xpColor
                                     : (isUnlocked ? Color.primary : Color.primary.opacity(0.25)))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(levelTitle(for: lvl))
                    .font(BaseStatTheme.Typography.bodySemibold)
                    .foregroundStyle(isUnlocked || isCurrent ? .primary : .tertiary)
                Text(lvl == 1 ? "Starting level" : "\(xpNeeded.asXPString) to reach · \((nextXP - xpNeeded).asXPString) to next")
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCurrent {
                Text("YOU")
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(BaseStatTheme.xpColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(BaseStatTheme.xpColor.opacity(0.18)))
            } else if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(BaseStatTheme.primaryTeal.opacity(0.5))
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(.horizontal, BaseStatTheme.Spacing.lg)
        .padding(.vertical, 10)
        .background(isCurrent ? BaseStatTheme.xpColor.opacity(0.06) : Color.clear)
    }

    private func xpThreshold(for level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (1..<level).reduce(0) { $0 + $1 * 500 }
    }

    private func levelTitle(for level: Int) -> String {
        switch level {
        case 1...4:   return "Rookie"
        case 5...9:   return "Apprentice"
        case 10...14: return "Warrior"
        case 15...19: return "Champion"
        case 20...29: return "Legend"
        case 30...49: return "Titan"
        default:      return "Immortal"
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 24) {
            GlassProgressRing(progress: 0.72, color: BaseStatTheme.primaryTeal)
            GlassProgressRing(progress: 0.45, color: BaseStatTheme.xpColor)
            GlassProgressRing(progress: 0.95, color: .green)
        }
    }
}
