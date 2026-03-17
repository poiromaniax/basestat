import SwiftUI

enum BaseStatTheme {

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat   = 4
        static let sm: CGFloat   = 8
        static let md: CGFloat   = 16
        static let lg: CGFloat   = 24
        static let xl: CGFloat   = 32
        static let xxl: CGFloat  = 48
    }

    // MARK: - Corner Radii
    enum Radius {
        static let sm: CGFloat   = 12
        static let md: CGFloat   = 20
        static let lg: CGFloat   = 28
        static let xl: CGFloat   = 36
        static let pill: CGFloat = 100
    }

    // MARK: - Font Styles
    enum Typography {
        static let heroTitle    = Font.system(size: 48, weight: .black, design: .rounded)
        static let title1       = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2       = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3       = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body         = Font.system(size: 16, weight: .regular)
        static let bodySemibold = Font.system(size: 16, weight: .semibold)
        static let caption      = Font.system(size: 13, weight: .medium)
        static let small        = Font.system(size: 11, weight: .medium)
        static let xpLabel      = Font.system(size: 14, weight: .bold, design: .monospaced)
        static let levelBadge   = Font.system(size: 20, weight: .black, design: .rounded)
    }

    // MARK: - Gradient Mesh Colors
    static var dashboardMeshColors: [Color] {
        [
            Color(red: 0.05, green: 0.08, blue: 0.20),
            Color(red: 0.00, green: 0.20, blue: 0.40),
            Color(red: 0.00, green: 0.30, blue: 0.50),
            Color(red: 0.05, green: 0.10, blue: 0.30),
            Color(red: 0.00, green: 0.25, blue: 0.45),
            Color(red: 0.10, green: 0.05, blue: 0.30),
            Color(red: 0.05, green: 0.05, blue: 0.15),
            Color(red: 0.00, green: 0.15, blue: 0.35),
            Color(red: 0.05, green: 0.08, blue: 0.20)
        ]
    }

    static var achievementMeshColors: [Color] {
        [
            Color(red: 0.10, green: 0.05, blue: 0.25),
            Color(red: 0.30, green: 0.10, blue: 0.40),
            Color(red: 0.20, green: 0.05, blue: 0.35),
            Color(red: 0.15, green: 0.08, blue: 0.30),
            Color(red: 0.40, green: 0.15, blue: 0.50),
            Color(red: 0.25, green: 0.08, blue: 0.40),
            Color(red: 0.10, green: 0.05, blue: 0.20),
            Color(red: 0.20, green: 0.08, blue: 0.30),
            Color(red: 0.10, green: 0.05, blue: 0.20)
        ]
    }

    static var profileMeshColors: [Color] {
        [
            Color(red: 0.00, green: 0.15, blue: 0.30),
            Color(red: 0.00, green: 0.30, blue: 0.45),
            Color(red: 0.00, green: 0.20, blue: 0.40),
            Color(red: 0.05, green: 0.20, blue: 0.35),
            Color(red: 0.00, green: 0.35, blue: 0.50),
            Color(red: 0.05, green: 0.25, blue: 0.45),
            Color(red: 0.00, green: 0.10, blue: 0.25),
            Color(red: 0.00, green: 0.20, blue: 0.35),
            Color(red: 0.00, green: 0.12, blue: 0.25)
        ]
    }

    // MARK: - Semantic Colors (defined in Assets.xcassets)
    static let xpColor      = Color("xpAmber")
    static let fireColor    = Color("streakFire")
    static let primaryTeal  = Color("primaryTeal")
    static let rarityCommon    = Color("achievementCommon")
    static let rarityRare      = Color("achievementRare")
    static let rarityEpic      = Color("achievementEpic")
    static let rarityLegendary = Color("achievementLegendary")

    // MARK: - XP Reward Values
    enum XPRewards {
        static let weightLog    = 30
        static let stepsGoal    = 50
        static let workout      = 75
        static let sleepGoal    = 40
        static let calorieGoal  = 30
        static let dailyLogin   = 10
        static let weekStreak   = 150
        static let monthStreak  = 500
    }

    // MARK: - Animation Durations
    enum Animation {
        static let fast: Double = 0.2
        static let normal: Double = 0.35
        static let slow: Double = 0.6
        static let levelUp: Double = 1.2
    }
}
