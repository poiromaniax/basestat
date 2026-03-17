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
