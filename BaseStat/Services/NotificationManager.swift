import Foundation
import UserNotifications

@MainActor
final class NotificationManager {

    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Streak Reminder

    func scheduleStreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["streak.daily"])
        var components = DateComponents()
        components.hour   = Constants.Notifications.streakReminderHour
        components.minute = Constants.Notifications.streakReminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Keep your streak alive! 🔥"
        content.body  = "Log in BaseStat today to protect your streak."
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.streakReminderCategoryId

        let request = UNNotificationRequest(identifier: "streak.daily", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Achievement Unlocked

    func notifyAchievementUnlocked(_ achievement: AchievementDefinition) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body  = "\"\(achievement.title)\" — \(achievement.description)"
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.achievementCategoryId

        let request = UNNotificationRequest(
            identifier: "achievement.\(achievement.id).\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        center.add(request)
    }

    // MARK: - Level Up

    func notifyLevelUp(newLevel: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Level Up! ⬆️"
        content.body  = "You reached Level \(newLevel)! Keep pushing your limits."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "levelup.\(newLevel)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        center.add(request)
    }

    // MARK: - Challenge Deadline

    func scheduleChallengeDueReminder(challenge: Challenge) {
        guard let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: challenge.endDate) else { return }
        guard twoDaysBefore > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: twoDaysBefore)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Challenge Ending Soon ⚡"
        content.body  = "\"\(challenge.title)\" ends in 2 days. You've got \(Int(challenge.progress * 100))% done — push it!"
        content.sound = .default
        content.categoryIdentifier = Constants.Notifications.challengeCategoryId

        let request = UNNotificationRequest(
            identifier: "challenge.\(challenge.id.uuidString)",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelChallengeNotification(challengeId: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["challenge.\(challengeId)"])
    }
}
