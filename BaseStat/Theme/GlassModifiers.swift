import SwiftUI

// MARK: - Primary Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Floating Glass Panel Modifier
struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Interactive Glass Button Modifier
struct GlassButtonModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - View Extensions

extension View {
    func baseStatGlassCard(cornerRadius: CGFloat = BaseStatTheme.Radius.md, padding: CGFloat = BaseStatTheme.Spacing.md) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }

    func baseStatGlassPanel(cornerRadius: CGFloat = BaseStatTheme.Radius.lg) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }

    func baseStatGlassButton(cornerRadius: CGFloat = BaseStatTheme.Radius.sm) -> some View {
        modifier(GlassButtonModifier(cornerRadius: cornerRadius))
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(BaseStatTheme.Typography.caption)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(1.2)
    }

    func metricValueStyle() -> some View {
        self
            .font(BaseStatTheme.Typography.title1)
            .foregroundStyle(.primary)
    }

    func xpLabelStyle() -> some View {
        self
            .font(BaseStatTheme.Typography.xpLabel)
            .foregroundStyle(BaseStatTheme.xpColor)
    }
}
