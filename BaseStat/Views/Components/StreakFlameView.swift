import SwiftUI

struct StreakFlameView: View {
    var count: Int
    var isActive: Bool
    var size: CGFloat = 44

    @State private var flicker: Bool = false

    var body: some View {
        ZStack {
            if isActive {
                // Glow halo
                Image(systemName: "flame.fill")
                    .font(.system(size: size * 1.15))
                    .foregroundStyle(BaseStatTheme.fireColor.opacity(0.25))
                    .blur(radius: 8)
                    .scaleEffect(flicker ? 1.08 : 0.95)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: flicker
                    )
            }

            // Flame
            Image(systemName: isActive ? "flame.fill" : "flame")
                .font(.system(size: size))
                .foregroundStyle(
                    isActive
                    ? LinearGradient(colors: [Color(red: 1, green: 0.7, blue: 0), Color(red: 1, green: 0.3, blue: 0)],
                                     startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                     startPoint: .top, endPoint: .bottom)
                )
                .scaleEffect(isActive && flicker ? 1.04 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: flicker)

            // Count badge
            Text("\(count)")
                .font(BaseStatTheme.Typography.small)
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(isActive ? Color(red: 1, green: 0.4, blue: 0) : Color.white.opacity(0.15))
                )
                .offset(x: size * 0.35, y: size * 0.35)
        }
        .frame(width: size * 1.5, height: size * 1.5)
        .onAppear { flicker = true }
    }
}

// MARK: - Compact Streak Badge

struct StreakBadge: View {
    var streak: Streak

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: streak.type.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(streak.isActiveToday ? BaseStatTheme.fireColor : .secondary)

            VStack(alignment: .leading, spacing: 1) {
                Text(streak.type.rawValue)
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
                Text("\(streak.currentCount) days")
                    .font(BaseStatTheme.Typography.caption)
                    .foregroundStyle(streak.isActiveToday ? .primary : .secondary)
            }

            Spacer()

            if streak.isAtRisk {
                Text("At risk!")
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.orange.opacity(0.15)))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 32) {
            StreakFlameView(count: 7, isActive: true)
            StreakFlameView(count: 0, isActive: false)
        }
    }
}
