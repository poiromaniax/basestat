import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var name: String = ""
    var totalXP: Int = 0
    var level: Int = 1
    var joinDate: Date = Date()
    var weightGoalKg: Double = 70.0
    var weightUnit: String = "kg"
    var onboardingComplete: Bool = false
    var photoData: Data?

    init(
        id: UUID = UUID(),
        name: String = "",
        totalXP: Int = 0,
        level: Int = 1,
        joinDate: Date = Date(),
        weightGoalKg: Double = 70.0,
        weightUnit: String = "kg",
        onboardingComplete: Bool = false
    ) {
        self.id = id
        self.name = name
        self.totalXP = totalXP
        self.level = level
        self.joinDate = joinDate
        self.weightGoalKg = weightGoalKg
        self.weightUnit = weightUnit
        self.onboardingComplete = onboardingComplete
    }

    var xpForCurrentLevel: Int {
        xpThreshold(for: level)
    }

    var xpForNextLevel: Int {
        xpThreshold(for: level + 1)
    }

    var xpInCurrentLevel: Int {
        totalXP - xpForCurrentLevel
    }

    var xpNeededForNextLevel: Int {
        xpForNextLevel - xpForCurrentLevel
    }

    var levelProgress: Double {
        guard xpNeededForNextLevel > 0 else { return 1.0 }
        return min(1.0, Double(xpInCurrentLevel) / Double(xpNeededForNextLevel))
    }

    var levelTitle: String {
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

    private func xpThreshold(for lvl: Int) -> Int {
        guard lvl > 1 else { return 0 }
        var total = 0
        for step in 1..<lvl {
            total += step * 500
        }
        return total
    }
}
