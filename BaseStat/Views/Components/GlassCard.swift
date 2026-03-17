import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = BaseStatTheme.Radius.md
    var padding: CGFloat = BaseStatTheme.Spacing.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Tinted Glass Card

struct TintedGlassCard<Content: View>: View {
    var tint: Color = .white
    var cornerRadius: CGFloat = BaseStatTheme.Radius.md
    var padding: CGFloat = BaseStatTheme.Spacing.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint.opacity(0.06))
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Previews

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.6), .purple.opacity(0.5)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
            .ignoresSafeArea()

        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading) {
                    Text("Steps Today")
                        .font(BaseStatTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                    Text("8,432")
                        .font(BaseStatTheme.Typography.title1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            TintedGlassCard(tint: .orange) {
                Text("Tinted Glass Card")
                    .font(BaseStatTheme.Typography.bodySemibold)
            }
        }
        .padding()
    }
}
