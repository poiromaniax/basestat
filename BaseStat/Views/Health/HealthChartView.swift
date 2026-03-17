import SwiftUI
import Charts

struct HealthChartView: View {
    var data: [MetricDataPoint]
    var metric: HealthMetricType
    var color: Color

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md, padding: BaseStatTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                Text("Last 30 Days")
                    .sectionHeaderStyle()

                if data.isEmpty {
                    emptyChart
                } else {
                    chart
                }
            }
        }
    }

    private var chart: some View {
        Chart(data) { point in
            if metric == .weight {
                LineMark(
                    x: .value("Date", point.date),
                    y: .value(metric.rawValue, point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                AreaMark(
                    x: .value("Date", point.date),
                    y: .value(metric.rawValue, point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.35), color.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            } else {
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value(metric.rawValue, point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .cornerRadius(3)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisValueLabel(format: .dateTime.month().day())
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
                AxisGridLine()
                    .foregroundStyle(Color.white.opacity(0.08))
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisValueLabel()
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
                AxisGridLine()
                    .foregroundStyle(Color.white.opacity(0.08))
            }
        }
        .frame(height: 180)
    }

    private var emptyChart: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title)
                    .foregroundStyle(.tertiary)
                Text("No data yet")
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .frame(height: 180)
    }
}
