import SwiftUI

struct MetricCardView: View {
    var title: String
    var value: String
    var unit: String
    var icon: String
    var color: Color
    var progress: Double?
    var isWide: Bool = false

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md, padding: BaseStatTheme.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.xs) {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(color)
                        Text(title)
                            .sectionHeaderStyle()
                    }

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(value)
                            .font(BaseStatTheme.Typography.title2)
                            .foregroundStyle(.primary)
                        Text(unit)
                            .font(BaseStatTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let progress {
                        ProgressBar(progress: progress, color: color)
                    }
                }

                Spacer()

                if let progress {
                    GlassProgressRing(
                        progress: progress,
                        lineWidth: 5,
                        size: 38,
                        color: color
                    )
                }
            }
            .frame(maxWidth: isWide ? .infinity : nil, alignment: .leading)
        }
    }
}

// MARK: - Compact ProgressBar

struct ProgressBar: View {
    var progress: Double
    var color: Color
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.10))
                    .frame(height: height)
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(1, max(0, progress)), height: height)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Stats Row

struct StatsRow: View {
    var label: String
    var value: String
    var icon: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 22)
            Text(label)
                .font(BaseStatTheme.Typography.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(BaseStatTheme.Typography.bodySemibold)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ZStack {
        GradientMeshBackground()
        VStack(spacing: 12) {
            MetricCardView(
                title: "Steps",
                value: "8,432",
                unit: "steps",
                icon: "figure.walk",
                color: BaseStatTheme.primaryTeal,
                progress: 0.84
            )
            MetricCardView(
                title: "Active Cal",
                value: "412",
                unit: "kcal",
                icon: "flame.fill",
                color: .orange,
                progress: 0.55
            )
        }
        .padding()
    }
}
