import SwiftUI

struct LevelUpOverlay: View {
    var newLevel: Int
    var onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var particleOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var shimmer: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: BaseStatTheme.Spacing.lg) {
                // Ripple rings
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(BaseStatTheme.xpColor.opacity(0.3 - Double(i) * 0.08), lineWidth: 2)
                            .frame(width: CGFloat(160 + i * 40), height: CGFloat(160 + i * 40))
                            .scaleEffect(ringScale)
                            .opacity(particleOpacity)
                    }

                    // Level badge
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [BaseStatTheme.xpColor.opacity(0.4), Color.clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)

                        VStack(spacing: 4) {
                            Text("LEVEL UP!")
                                .font(BaseStatTheme.Typography.caption)
                                .foregroundStyle(BaseStatTheme.xpColor.opacity(0.8))
                                .tracking(3)

                            Text("\(newLevel)")
                                .font(.system(size: 72, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [BaseStatTheme.xpColor, Color.orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                            Text("REACHED")
                                .font(BaseStatTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                                .tracking(2)
                        }
                    }
                    .scaleEffect(scale)
                }

                // Title and hint
                VStack(spacing: BaseStatTheme.Spacing.sm) {
                    Text(levelTitle(for: newLevel))
                        .font(BaseStatTheme.Typography.title2)
                        .foregroundStyle(.primary)

                    Text("Keep going — greatness awaits")
                        .font(BaseStatTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .opacity(opacity)

                Button {
                    dismiss()
                } label: {
                    Text("Let's Go!")
                        .font(BaseStatTheme.Typography.bodySemibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .baseStatGlassButton(cornerRadius: BaseStatTheme.Radius.pill)
                }
                .opacity(opacity)
            }
            .padding(BaseStatTheme.Spacing.xl)
        }
        .onAppear { animate() }
    }

    private func animate() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
            scale = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            ringScale = 1.5
            particleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            opacity = 1
        }
        withAnimation(.easeIn(duration: 0.8).delay(1.0)) {
            particleOpacity = 0
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.25)) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
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
    LevelUpOverlay(newLevel: 10) {}
}
