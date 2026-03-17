import Foundation
import HealthKit
import Observation

@Observable
@MainActor
final class HealthKitManager {

    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    // MARK: - Published State
    var isAuthorized: Bool = false
    var latestWeightKg: Double?
    var todaySteps: Int = 0
    var todayActiveCalories: Double = 0
    var todayBasalCalories: Double = 0
    var todayExerciseMinutes: Int = 0
    var lastNightSleepHours: Double = 0
    var restingHeartRate: Double?
    var averageHeartRate: Double?
    var todayDistanceKm: Double = 0
    var todayDietaryCalories: Double = 0

    // MARK: - HealthKit Types

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let quantities: [HKQuantityTypeIdentifier] = [
            .bodyMass, .bodyMassIndex, .stepCount,
            .activeEnergyBurned,
            .appleExerciseTime, .heartRate, .restingHeartRate,
            .distanceWalkingRunning, .dietaryEnergyConsumed, .basalEnergyBurned
        ]
        for id in quantities {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        if let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        types.insert(HKObjectType.workoutType())
        return types
    }

    private var writeTypes: Set<HKSampleType> {
        var types = Set<HKSampleType>()
        if let weight = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            types.insert(weight)
        }
        return types
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
        isAuthorized = true
        await refreshAll()
    }

    // MARK: - Full Refresh

    func refreshAll() async {
        async let weight   = fetchLatestWeight()
        async let steps    = fetchTodaySteps()
        async let active   = fetchTodayActiveCalories()
        async let basal    = fetchTodayBasalCalories()
        async let exercise = fetchTodayExerciseMinutes()
        async let sleep    = fetchLastNightSleep()
        async let rhr      = fetchRestingHeartRate()
        async let distance = fetchTodayDistance()
        async let dietary  = fetchTodayDietaryCalories()

        let (wt, st, ac, bs, ex, sl, rhr2, dist, diet) = await (
            weight, steps, active, basal, exercise, sleep, rhr, distance, dietary
        )

        await MainActor.run {
            latestWeightKg       = wt
            todaySteps           = st
            todayActiveCalories  = ac
            todayBasalCalories   = bs
            todayExerciseMinutes = ex
            lastNightSleepHours  = sl
            restingHeartRate     = rhr2
            todayDistanceKm      = dist
            todayDietaryCalories = diet
        }
    }

    // MARK: - Snapshot Builder

    func buildTodaySnapshot() async -> HealthSnapshot {
        await refreshAll()
        return HealthSnapshot(
            date: Date(),
            weightKg: latestWeightKg,
            steps: todaySteps,
            activeCalories: todayActiveCalories,
            basalCalories: todayBasalCalories,
            exerciseMinutes: todayExerciseMinutes,
            heartRateResting: restingHeartRate,
            heartRateAverage: averageHeartRate,
            sleepHours: lastNightSleepHours,
            dietaryCalories: todayDietaryCalories,
            distanceKm: todayDistanceKm
        )
    }

    // MARK: - Historical Data

    func fetchWeightHistory(days: Int) async -> [(date: Date, kg: Double)] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return await fetchQuantitySamples(type: type, from: start, unit: HKUnit.gramUnit(with: .kilo))
    }

    func fetchStepsHistory(days: Int) async -> [(date: Date, value: Double)] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return await fetchDailyStatistics(type: type, from: start, unit: HKUnit.count())
    }

    func fetchActiveCaloriesHistory(days: Int) async -> [(date: Date, value: Double)] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return await fetchDailyStatistics(type: type, from: start, unit: HKUnit.kilocalorie())
    }

    func fetchSleepHistory(days: Int) async -> [(date: Date, hours: Double)] {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                var dailySleep: [Date: Double] = [:]
                for sample in (samples as? [HKCategorySample]) ?? [] {
                    guard sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue else { continue }
                    let day = Calendar.current.startOfDay(for: sample.startDate)
                    let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                    dailySleep[day, default: 0] += hours
                }
                let result = dailySleep.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }
                continuation.resume(returning: result)
            }
            store.execute(query)
        }
    }

    // MARK: - Today Fetchers

    private func fetchLatestWeight() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-30 * 86400), end: Date())
        return await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func fetchTodaySteps() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        let value = await fetchTodaySum(type: type, unit: HKUnit.count())
        return Int(value)
    }

    private func fetchTodayActiveCalories() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return 0 }
        return await fetchTodaySum(type: type, unit: HKUnit.kilocalorie())
    }

    private func fetchTodayBasalCalories() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else { return 0 }
        return await fetchTodaySum(type: type, unit: HKUnit.kilocalorie())
    }

    private func fetchTodayExerciseMinutes() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return 0 }
        let value = await fetchTodaySum(type: type, unit: HKUnit.minute())
        return Int(value)
    }

    private func fetchTodayDistance() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return 0 }
        return await fetchTodaySum(type: type, unit: HKUnit.meterUnit(with: .kilo))
    }

    private func fetchTodayDietaryCalories() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else { return 0 }
        return await fetchTodaySum(type: type, unit: HKUnit.kilocalorie())
    }

    private func fetchLastNightSleep() async -> Double {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        let yesterday = Calendar.current.date(byAdding: .hour, value: -18, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                var total = 0.0
                for sample in (samples as? [HKCategorySample]) ?? [] {
                    guard sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                          sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue else { continue }
                    total += sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                }
                continuation.resume(returning: total)
            }
            store.execute(query)
        }
    }

    private func fetchRestingHeartRate() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return nil }
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min"))
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    // MARK: - Helpers

    private func fetchTodaySum(type: HKQuantityType, unit: HKUnit) async -> Double {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum
            ) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }

    private func fetchQuantitySamples(type: HKQuantityType, from start: Date, unit: HKUnit) async -> [(date: Date, kg: Double)] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(
                sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]
            ) { _, samples, _ in
                let result = (samples as? [HKQuantitySample] ?? []).map { ($0.startDate, $0.quantity.doubleValue(for: unit)) }
                continuation.resume(returning: result)
            }
            store.execute(query)
        }
    }

    private func fetchDailyStatistics(type: HKQuantityType, from start: Date, unit: HKUnit) async -> [(date: Date, value: Double)] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let interval = DateComponents(day: 1)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: type, quantitySamplePredicate: predicate,
                options: .cumulativeSum, anchorDate: start, intervalComponents: interval
            )
            query.initialResultsHandler = { _, collection, _ in
                var results: [(Date, Double)] = []
                collection?.enumerateStatistics(from: start, to: Date()) { stats, _ in
                    results.append((stats.startDate, stats.sumQuantity()?.doubleValue(for: unit) ?? 0))
                }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }
}
