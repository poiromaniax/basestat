import Foundation
import SwiftData

@Model
final class HealthSnapshot {
    var id: UUID
    var date: Date
    var weightKg: Double?
    var bmi: Double?
    var steps: Int
    var activeCalories: Double
    var basalCalories: Double
    var exerciseMinutes: Int
    var heartRateResting: Double?
    var heartRateAverage: Double?
    var sleepHours: Double
    var dietaryCalories: Double
    var distanceKm: Double

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weightKg: Double? = nil,
        bmi: Double? = nil,
        steps: Int = 0,
        activeCalories: Double = 0,
        basalCalories: Double = 0,
        exerciseMinutes: Int = 0,
        heartRateResting: Double? = nil,
        heartRateAverage: Double? = nil,
        sleepHours: Double = 0,
        dietaryCalories: Double = 0,
        distanceKm: Double = 0
    ) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.bmi = bmi
        self.steps = steps
        self.activeCalories = activeCalories
        self.basalCalories = basalCalories
        self.exerciseMinutes = exerciseMinutes
        self.heartRateResting = heartRateResting
        self.heartRateAverage = heartRateAverage
        self.sleepHours = sleepHours
        self.dietaryCalories = dietaryCalories
        self.distanceKm = distanceKm
    }

    var totalCalories: Double {
        activeCalories + basalCalories
    }

    var stepsGoalProgress: Double {
        min(1.0, Double(steps) / 10_000.0)
    }

    var exerciseGoalProgress: Double {
        min(1.0, Double(exerciseMinutes) / 30.0)
    }

    var sleepGoalProgress: Double {
        min(1.0, sleepHours / 8.0)
    }
}
