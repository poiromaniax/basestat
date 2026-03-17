import SwiftUI

struct HealthDetailRootView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                StaticMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

                ScrollView {
                    LazyVStack(spacing: BaseStatTheme.Spacing.sm) {
                        ForEach(HealthMetricType.allCases) { metric in
                            NavigationLink {
                                HealthDetailView(metric: metric)
                            } label: {
                                MetricRowLink(metric: metric)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(BaseStatTheme.Spacing.md)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Health Metrics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MetricRowLink: View {
    var metric: HealthMetricType

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md, padding: BaseStatTheme.Spacing.md) {
            HStack {
                Image(systemName: metric.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(metricColor(metric))
                    .frame(width: 36, height: 36)
                    .background(metricColor(metric).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(metric.rawValue)
                    .font(BaseStatTheme.Typography.bodySemibold)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    func metricColor(_ metric: HealthMetricType) -> Color {
        switch metric {
        case .weight:    return .cyan
        case .steps:     return BaseStatTheme.primaryTeal
        case .calories:  return .orange
        case .exercise:  return .green
        case .sleep:     return .indigo
        case .heartRate: return .red
        }
    }
}

struct HealthDetailView: View {
    var metric: HealthMetricType
    @State private var viewModel = HealthDetailViewModel()

    var body: some View {
        ZStack {
            StaticMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

            ScrollView {
                VStack(spacing: BaseStatTheme.Spacing.md) {
                    statsCards
                    HealthChartView(
                        data: viewModel.chartData,
                        metric: metric,
                        color: metricColor
                    )
                    insightsCard
                }
                .padding(BaseStatTheme.Spacing.md)
                .padding(.bottom, BaseStatTheme.Spacing.xxl)
            }
        }
        .navigationTitle(metric.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load(metric: metric) }
    }

    private var statsCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: BaseStatTheme.Spacing.sm) {
            StatsCell(
                label: "Best",
                value: formattedValue(viewModel.personalBest),
                unit: metric.unit,
                icon: "trophy.fill",
                color: BaseStatTheme.xpColor
            )
            StatsCell(
                label: "7-Day Avg",
                value: formattedValue(viewModel.weekAverage),
                unit: metric.unit,
                icon: "chart.bar.fill",
                color: BaseStatTheme.primaryTeal
            )
            StatsCell(
                label: "Trend",
                value: viewModel.trendLabel,
                unit: "",
                icon: viewModel.isTrendPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                color: viewModel.isTrendPositive ? .green : .red
            )
        }
    }

    private var insightsCard: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                Text("Insights")
                    .sectionHeaderStyle()

                VStack(alignment: .leading, spacing: 8) {
                    InsightRow(
                        icon: "lightbulb.fill",
                        color: BaseStatTheme.xpColor,
                        text: insightText
                    )
                    if let avg = viewModel.weekAverage {
                        InsightRow(
                            icon: "clock.fill",
                            color: .cyan,
                            text: "Your 7-day average is \(formattedValue(avg)) \(metric.unit)"
                        )
                    }
                }
            }
        }
    }

    private var insightText: String {
        switch metric {
        case .steps:    return "Hitting 10,000 steps per day reduces risk of cardiovascular disease."
        case .sleep:    return "7–9 hours of sleep optimizes recovery, performance, and weight loss."
        case .calories: return "Consistent calorie burn is key to sustainable weight loss."
        case .exercise: return "30 minutes of daily exercise is linked to longer life expectancy."
        case .weight:   return "Gradual weight loss of 0.5–1 kg/week is the most sustainable approach."
        case .heartRate: return "A lower resting heart rate indicates better cardiovascular fitness."
        }
    }

    private var metricColor: Color {
        switch metric {
        case .weight:    return .cyan
        case .steps:     return BaseStatTheme.primaryTeal
        case .calories:  return .orange
        case .exercise:  return .green
        case .sleep:     return .indigo
        case .heartRate: return .red
        }
    }

    private func formattedValue(_ input: Double?) -> String {
        guard let num = input else { return "—" }
        return num >= 100 ? "\(Int(num))" : String(format: "%.1f", num)
    }
}

// MARK: - Supporting Views

struct StatsCell: View {
    var label: String
    var value: String
    var unit: String
    var icon: String
    var color: Color

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.sm, padding: BaseStatTheme.Spacing.sm) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(value)
                    .font(BaseStatTheme.Typography.title3)
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                if !unit.isEmpty {
                    Text(unit)
                        .font(BaseStatTheme.Typography.small)
                        .foregroundStyle(.secondary)
                }
                Text(label)
                    .sectionHeaderStyle()
            }
        }
    }
}

struct InsightRow: View {
    var icon: String
    var color: Color
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 18)
                .padding(.top, 2)
            Text(text)
                .font(BaseStatTheme.Typography.body)
                .foregroundStyle(.secondary)
        }
    }
}
