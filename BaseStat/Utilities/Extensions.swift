import SwiftUI
import Foundation

// MARK: - Double
extension Double {
    func formatted(decimals: Int) -> String {
        String(format: "%.\(decimals)f", self)
    }

    var asWeightString: String {
        String(format: "%.1f", self)
    }

    var asCaloriesString: String {
        let rounded = Int(self.rounded())
        return "\(rounded)"
    }
}

// MARK: - Int
extension Int {
    var formattedSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var asXPString: String {
        "+\(self) XP"
    }
}

// MARK: - Date
extension Date {
    var shortDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }

    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
}

// MARK: - Color
extension Color {
    static var glassBackground: Color {
        Color.white.opacity(0.08)
    }
    static var glassBorder: Color {
        Color.white.opacity(0.15)
    }
}

// MARK: - View
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.glassBackground)
            .overlay(
                RoundedRectangle(cornerRadius: BaseStatTheme.Radius.md, style: .continuous)
                    .strokeBorder(Color.glassBorder, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: BaseStatTheme.Radius.md, style: .continuous))
    }
}

// MARK: - AchievementRarity Color
extension AchievementRarity {
    var swiftUIColor: Color {
        switch self {
        case .common:    return Color(red: 0.7, green: 0.75, blue: 0.80)
        case .rare:      return Color(red: 0.30, green: 0.60, blue: 1.00)
        case .epic:      return Color(red: 0.65, green: 0.25, blue: 1.00)
        case .legendary: return Color(red: 1.00, green: 0.75, blue: 0.10)
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .common:
            return [Color(red: 0.6, green: 0.65, blue: 0.70), Color(red: 0.4, green: 0.45, blue: 0.50)]
        case .rare:
            return [Color(red: 0.30, green: 0.60, blue: 1.00), Color(red: 0.10, green: 0.35, blue: 0.80)]
        case .epic:
            return [Color(red: 0.80, green: 0.35, blue: 1.00), Color(red: 0.45, green: 0.10, blue: 0.80)]
        case .legendary:
            return [Color(red: 1.00, green: 0.85, blue: 0.20), Color(red: 1.00, green: 0.50, blue: 0.00)]
        }
    }
}
