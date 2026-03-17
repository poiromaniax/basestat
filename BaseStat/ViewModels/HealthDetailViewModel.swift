import Foundation
import SwiftData
import Observation

enum HealthMetricType: String, CaseIterable, Identifiable {
    case weight    = "Weight"
    case steps     = "Steps"
    case calories  = "Calories"
    case exercise  = "Exercise"
    case sleep     = "Sleep"
    case heartRate = "Heart Rate"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .weight:    return "scalemass.fill"
        case .steps:     return "figure.walk"
        case .calories:  return "flame.fill"
        case .exercise:  return "timer"
        case .sleep:     return "moon.zzz.fill"
        case .heartRate: return "heart.fill"
        }
    }

    var unit: String {
        switch self {
        case .weight:    return "kg"
        case .steps:     return "steps"
        case .calories:  return "kcal"
        case .exercise:  return "min"
        case .sleep:     return "hrs"
        case .heartRate: return "bpm"
        }
    }
}

struct MetricDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

@Observable
@MainActor
final class HealthDetailViewModel {

    var selectedMetric: HealthMetricType = .steps
    var chartData: [MetricDataPoint] = []
    var isLoading: Bool = false
    var personalBest: Double?
    var weekAverage: Double?
    var trend: Double = 0

    private let healthKit = HealthKitManager.shared

    func load(metric: HealthMetricType) async {
        selectedMetric = metric
        await MainActor.run { isLoading = true }
        await fetchHistory(for: metric, days: 30)
        computeStats()
        await MainActor.run { isLoading = false }
    }

    private func fetchHistory(for metric: HealthMetricType, days: Int) async {
        var points: [MetricDataPoint] = []

        switch metric {
        case .weight:
            let data = await healthKit.fetchWeightHistory(days: days)
            points = data.map { MetricDataPoint(date: $0.date, value: $0.kg) }
        case .steps:
            let data = await healthKit.fetchStepsHistory(days: days)
            points = data.map { MetricDataPoint(date: $0.date, value: $0.value) }
        case .calories:
            let data = await healthKit.fetchActiveCaloriesHistory(days: days)
            points = data.map { MetricDataPoint(date: $0.date, value: $0.value) }
        case .sleep:
            let data = await healthKit.fetchSleepHistory(days: days)
            points = data.map { MetricDataPoint(date: $0.date, value: $0.hours) }
        case .exercise, .heartRate:
            points = []
        }

        await MainActor.run {
            chartData = points.filter { $0.value > 0 }
        }
    }

    private func computeStats() {
        guard !chartData.isEmpty else { return }
        let values = chartData.map(\.value)

        switch selectedMetric {
        case .weight:
            personalBest = values.min()
        default:
            personalBest = values.max()
        }

        let last7 = Array(values.suffix(7))
        weekAverage = last7.isEmpty ? nil : last7.reduce(0, +) / Double(last7.count)

        if values.count >= 2 {
            let first = values.prefix(values.count / 2).reduce(0, +) / Double(values.count / 2)
            let last  = values.suffix(values.count / 2).reduce(0, +) / Double(values.count / 2)
            trend = first > 0 ? (last - first) / first * 100 : 0
        }
    }

    var trendLabel: String {
        if trend > 0 { return String(format: "+%.1f%%", trend) }
        if trend < 0 { return String(format: "%.1f%%", trend) }
        return "Steady"
    }

    var isTrendPositive: Bool {
        switch selectedMetric {
        case .weight: return trend < 0
        default:      return trend > 0
        }
    }
}
