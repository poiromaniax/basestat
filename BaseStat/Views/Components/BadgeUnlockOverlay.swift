import SwiftUI

struct BadgeUnlockOverlay: View {
    var achievement: AchievementDefinition
    var hasMore: Bool
    var onDismiss: () -> Void

    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: BaseStatTheme.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(achievement.rarity.swiftUIColor.opacity(glowPulse ? 0.35 : 0.15))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .scaleEffect(glowPulse ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: achievement.rarity.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.45), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .offset(x: shimmerOffset)
                                .clipped()
                        }
                        .clipShape(Circle())
                        .shadow(color: achievement.rarity.swiftUIColor.opacity(0.6), radius: 20)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
                .scaleEffect(scale)

                VStack(spacing: BaseStatTheme.Spacing.sm) {
                    Text("Achievement Unlocked!")
                        .font(BaseStatTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .tracking(2)

                    Text(achievement.title)
                        .font(BaseStatTheme.Typography.title2)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text(achievement.description)
                        .font(BaseStatTheme.Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text(achievement.xpReward.asXPString)
                            .font(BaseStatTheme.Typography.xpLabel)
                    }
                    .foregroundStyle(BaseStatTheme.xpColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(BaseStatTheme.xpColor.opacity(0.15)))
                }
                .opacity(opacity)

                Button {
                    dismiss()
                } label: {
                    Text(hasMore ? "Next" : "Got it!")
                        .font(BaseStatTheme.Typography.bodySemibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule()
                                .fill(achievement.rarity.swiftUIColor.opacity(0.35))
                                .glassEffect(.regular.interactive(), in: Capsule())
                        )
                }
                .opacity(opacity)
            }
            .padding(BaseStatTheme.Spacing.xl)
        }
        .onAppear { animate() }
    }

    private func animate() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            opacity = 1
        }
        withAnimation(.linear(duration: 0.7).delay(0.5)) {
            shimmerOffset = 200
        }
        glowPulse = true
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            scale = 0.7
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

#Preview {
    BadgeUnlockOverlay(achievement: AchievementCatalog.all[3], hasMore: false) {}
}
