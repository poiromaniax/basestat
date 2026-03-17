import SwiftUI

struct XPProgressBar: View {
    var profile: UserProfile
    var showLabel: Bool = true

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.xs) {
            if showLabel {
                HStack {
                    Text("Level \(profile.level) · \(profile.levelTitle)")
                        .font(BaseStatTheme.Typography.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(profile.xpInCurrentLevel) / \(profile.xpNeededForNextLevel) XP")
                        .font(BaseStatTheme.Typography.xpLabel)
                        .foregroundStyle(BaseStatTheme.xpColor)
                }
            }

            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: BaseStatTheme.Radius.pill)
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 10)

                // Fill
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: BaseStatTheme.Radius.pill)
                        .fill(
                            LinearGradient(
                                colors: [BaseStatTheme.xpColor, Color.orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress)
                        .shadow(color: BaseStatTheme.xpColor.opacity(0.5), radius: 4, x: 0, y: 0)
                }
                .frame(height: 10)

                // Glass overlay shimmer
                RoundedRectangle(cornerRadius: BaseStatTheme.Radius.pill)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 10)
                    .glassEffect(in: RoundedRectangle(cornerRadius: BaseStatTheme.Radius.pill))
            }
            .frame(height: 10)
        }
        .onAppear {
            withAnimation(.spring(duration: BaseStatTheme.Animation.slow).delay(0.1)) {
                animatedProgress = profile.levelProgress
            }
        }
        .onChange(of: profile.levelProgress) { _, newVal in
            withAnimation(.spring(duration: BaseStatTheme.Animation.normal)) {
                animatedProgress = newVal
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.07, blue: 0.18).ignoresSafeArea()
        let profile = UserProfile(name: "Ariel", totalXP: 3200, level: 7)
        XPProgressBar(profile: profile)
            .padding()
    }
}
