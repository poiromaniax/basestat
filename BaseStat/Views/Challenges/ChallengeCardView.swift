import SwiftUI

struct ChallengeCardView: View {
    var challenge: Challenge
    var onAbandon: (() -> Void)?

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: challenge.metric.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(statusColor)
                            Text(challenge.metric.rawValue.uppercased())
                                .sectionHeaderStyle()
                        }
                        Text(challenge.title)
                            .font(BaseStatTheme.Typography.title3)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    statusBadge
                }

                Text(challenge.challengeDescription)
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // Progress row
                VStack(spacing: 6) {
                    HStack {
                        Text("\(progressLabel) / \(targetLabel)")
                            .font(BaseStatTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(challenge.progress * 100))%")
                            .font(BaseStatTheme.Typography.xpLabel)
                            .foregroundStyle(statusColor)
                    }
                    ProgressBar(progress: challenge.progress, color: statusColor, height: 6)
                }

                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11))
                        Text("\(challenge.xpReward) XP")
                            .font(BaseStatTheme.Typography.caption)
                    }
                    .foregroundStyle(BaseStatTheme.xpColor)

                    Spacer()

                    if !challenge.isCompleted, let abandon = onAbandon {
                        Button(action: abandon) {
                            Text("Abandon")
                                .font(BaseStatTheme.Typography.small)
                                .foregroundStyle(.red.opacity(0.7))
                        }
                    }

                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }

    private var statusColor: Color {
        if challenge.isCompleted { return .green }
        if challenge.isExpired { return .gray }
        if challenge.progress >= 0.75 { return .orange }
        return BaseStatTheme.primaryTeal
    }

    private var statusBadge: some View {
        Text(challenge.statusLabel)
            .font(BaseStatTheme.Typography.small)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(statusColor.opacity(0.15)))
    }

    private var progressLabel: String {
        let val = challenge.currentValue
        switch challenge.metric {
        case .steps:           return "\(Int(val).formattedSteps)"
        case .activeCalories:  return "\(Int(val)) kcal"
        case .exerciseMinutes: return "\(Int(val)) min"
        case .weightLoss:      return String(format: "%.1f kg", val)
        case .sleepHours:      return String(format: "%.1f hrs", val)
        case .workouts:        return "\(Int(val)) workouts"
        }
    }

    private var targetLabel: String {
        let val = challenge.targetValue
        switch challenge.metric {
        case .steps:           return "\(Int(val).formattedSteps)"
        case .activeCalories:  return "\(Int(val)) kcal"
        case .exerciseMinutes: return "\(Int(val)) min"
        case .weightLoss:      return String(format: "%.1f kg", val)
        case .sleepHours:      return String(format: "%.1f hrs", val)
        case .workouts:        return "\(Int(val)) workouts"
        }
    }
}

// MARK: - Template Card

struct ChallengeTemplateCard: View {
    var template: ChallengeTemplate
    var onStart: () -> Void

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                HStack {
                    Image(systemName: template.metric.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(BaseStatTheme.primaryTeal)
                    Text(template.metric.rawValue.uppercased())
                        .sectionHeaderStyle()
                    Spacer()
                    Text("\(template.durationDays)d")
                        .font(BaseStatTheme.Typography.small)
                        .foregroundStyle(.secondary)
                }
                Text(template.title)
                    .font(BaseStatTheme.Typography.title3)
                Text(template.description)
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill").font(.system(size: 11))
                        Text("\(template.xpReward) XP")
                            .font(BaseStatTheme.Typography.caption)
                    }
                    .foregroundStyle(BaseStatTheme.xpColor)
                    Spacer()
                    Button(action: onStart) {
                        Text("Start")
                            .font(BaseStatTheme.Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .baseStatGlassButton(cornerRadius: BaseStatTheme.Radius.pill)
                    }
                }
            }
        }
    }
}
