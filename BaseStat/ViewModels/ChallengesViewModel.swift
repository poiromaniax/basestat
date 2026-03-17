import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class ChallengesViewModel {

    var activeChallenges: [Challenge] = []
    var completedChallenges: [Challenge] = []
    var expiredChallenges: [Challenge] = []
    var showingTemplates: Bool = false

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Challenge>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        let all = (try? context.fetch(descriptor)) ?? []
        activeChallenges    = all.filter { $0.isActive && !$0.isCompleted && !$0.isExpired }
        completedChallenges = all.filter { $0.isCompleted }
        expiredChallenges   = all.filter { $0.isExpired }
    }

    func startChallenge(_ template: ChallengeTemplate, context: ModelContext) {
        let challenge = template.makeChallenge()
        context.insert(challenge)
        NotificationManager.shared.scheduleChallengeDueReminder(challenge: challenge)
        try? context.save()
        load(context: context)
    }

    func abandonChallenge(_ challenge: Challenge, context: ModelContext) {
        NotificationManager.shared.cancelChallengeNotification(challengeId: challenge.id.uuidString)
        challenge.isActive = false
        try? context.save()
        load(context: context)
    }

    var availableTemplates: [ChallengeTemplate] {
        let activeIds = activeChallenges.map(\.title)
        return ChallengeTemplates.all.filter { !activeIds.contains($0.title) }
    }

    var totalXPFromChallenges: Int {
        completedChallenges.reduce(0) { $0 + $1.xpReward }
    }
}
