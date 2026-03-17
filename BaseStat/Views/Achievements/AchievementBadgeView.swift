import SwiftUI

struct AchievementBadgeView: View {
    var definition: AchievementDefinition
    var isUnlocked: Bool
    var unlockedDate: Date?
    var size: CGFloat = 80

    @State private var pressed = false

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
    }

    private var badgeCircle: some View {
        ZStack {
            if isUnlocked {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [definition.rarity.swiftUIColor.opacity(0.45), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.6
                        )
                    )
                    .frame(width: size + 20, height: size + 20)
                    .blur(radius: 8)

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
    var definition: AchievementDefinition
    var isUnlocked: Bool
    var unlockedDate: Date?

    var body: some View {
        ZStack {
            StaticMeshBackground(colors: BaseStatTheme.achievementMeshColors)

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
                            .padding(.top, 4)
                    } else {
                        Text("Not yet unlocked")
                            .font(BaseStatTheme.Typography.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
                    }
                }

                Spacer()
            }
            .padding(.top, BaseStatTheme.Spacing.xxl)
            .padding(.horizontal, BaseStatTheme.Spacing.lg)
        }
    }

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
