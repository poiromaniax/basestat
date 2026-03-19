import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    var onComplete: () -> Void

    @State private var page: Int = 0
    @State private var name: String = ""
    @State private var goalWeight: String = ""
    @State private var weightUnit: String = "kg"
    @State private var requestingHealth = false
    @State private var historyOption: Constants.HistoryOption = .oneYear

    private let totalPages = 5

    var body: some View {
        ZStack {
            GradientMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    welcomePage.tag(0)
                    namePage.tag(1)
                    goalPage.tag(2)
                    healthPermissionPage.tag(3)
                    historyPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(duration: BaseStatTheme.Animation.normal), value: page)

                pageIndicator
                    .padding(.bottom, BaseStatTheme.Spacing.md)

                navigationButtons
                    .padding(.horizontal, BaseStatTheme.Spacing.lg)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
            }
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: BaseStatTheme.Spacing.lg) {
            Spacer()
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: BaseStatTheme.primaryTeal.opacity(0.6), radius: 24)

            VStack(spacing: BaseStatTheme.Spacing.sm) {
                Text("Welcome to BaseStat")
                    .font(BaseStatTheme.Typography.heroTitle)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Your health journey, gamified.\nLevel up your life.")
                    .font(BaseStatTheme.Typography.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                VStack(spacing: BaseStatTheme.Spacing.md) {
                    FeatureRow(icon: "star.fill", color: BaseStatTheme.xpColor,
                               title: "Earn XP & Level Up", subtitle: "Every healthy choice earns experience points")
                    FeatureRow(icon: "trophy.fill", color: .yellow,
                               title: "Unlock Achievements", subtitle: "30+ badges to collect on your journey")
                    FeatureRow(icon: "flame.fill", color: BaseStatTheme.fireColor,
                               title: "Build Streaks", subtitle: "Keep daily streaks to multiply your rewards")
                    FeatureRow(icon: "heart.fill", color: .red,
                               title: "Apple Health Sync", subtitle: "Automatically tracks your health data")
                }
            }
            Spacer()
        }
        .padding(.horizontal, BaseStatTheme.Spacing.lg)
    }

    private var namePage: some View {
        VStack(spacing: BaseStatTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .purple.opacity(0.4), radius: 16)

            VStack(spacing: BaseStatTheme.Spacing.sm) {
                Text("What's your name?")
                    .font(BaseStatTheme.Typography.title1)
                Text("We'll use this to personalize your experience.")
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                TextField("Enter your name", text: $name)
                    .font(BaseStatTheme.Typography.title3)
                    .multilineTextAlignment(.center)
                    .submitLabel(.next)
                    .onSubmit { if !name.isEmpty { withAnimation { page = 2 } } }
            }
            Spacer()
        }
        .padding(.horizontal, BaseStatTheme.Spacing.lg)
    }

    private var goalPage: some View {
        VStack(spacing: BaseStatTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 72))
                .foregroundStyle(LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .green.opacity(0.4), radius: 16)

            VStack(spacing: BaseStatTheme.Spacing.sm) {
                Text("Set Your Goal Weight")
                    .font(BaseStatTheme.Typography.title1)
                Text("This helps us track your progress and unlock weight achievements.")
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                VStack(spacing: BaseStatTheme.Spacing.md) {
                    HStack(spacing: BaseStatTheme.Spacing.sm) {
                        TextField("e.g. 75", text: $goalWeight)
                            .font(BaseStatTheme.Typography.title2)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 120)

                        Picker("Unit", selection: $weightUnit) {
                            Text("kg").tag("kg")
                            Text("lbs").tag("lbs")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, BaseStatTheme.Spacing.lg)
    }

    private var healthPermissionPage: some View {
        VStack(spacing: BaseStatTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "heart.text.clipboard.fill")
                .font(.system(size: 72))
                .foregroundStyle(LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .red.opacity(0.4), radius: 16)

            VStack(spacing: BaseStatTheme.Spacing.sm) {
                Text("Connect Apple Health")
                    .font(BaseStatTheme.Typography.title1)
                Text("BaseStat reads your health data to automatically award XP and track progress. No data leaves your device.")
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                VStack(spacing: BaseStatTheme.Spacing.sm) {
                    HealthPermissionRow(icon: "scalemass.fill", color: .cyan, label: "Weight & BMI")
                    HealthPermissionRow(icon: "figure.walk", color: BaseStatTheme.primaryTeal, label: "Steps & Distance")
                    HealthPermissionRow(icon: "flame.fill", color: .orange, label: "Calories Burned")
                    HealthPermissionRow(icon: "timer", color: .green, label: "Exercise Minutes")
                    HealthPermissionRow(icon: "heart.fill", color: .red, label: "Heart Rate")
                    HealthPermissionRow(icon: "moon.zzz.fill", color: .indigo, label: "Sleep Analysis")
                }
            }
            Spacer()
        }
        .padding(.horizontal, BaseStatTheme.Spacing.lg)
    }

    private var historyPage: some View {
        VStack(spacing: BaseStatTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 72))
                .foregroundStyle(LinearGradient(colors: [BaseStatTheme.primaryTeal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: BaseStatTheme.primaryTeal.opacity(0.4), radius: 16)

            VStack(spacing: BaseStatTheme.Spacing.sm) {
                Text("Import Health History")
                    .font(BaseStatTheme.Typography.title1)
                Text("Choose how far back to pull your Apple Health data. More history unlocks more personal records and achievements.")
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                VStack(spacing: BaseStatTheme.Spacing.xs) {
                    ForEach(Constants.HistoryOption.allCases) { option in
                        Button {
                            withAnimation(.spring(duration: 0.2)) { historyOption = option }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.label)
                                        .font(BaseStatTheme.Typography.bodySemibold)
                                        .foregroundStyle(.primary)
                                    Text(option.description)
                                        .font(BaseStatTheme.Typography.small)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if historyOption == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(BaseStatTheme.primaryTeal)
                                }
                            }
                            .padding(.vertical, BaseStatTheme.Spacing.xs)
                        }
                        if option != Constants.HistoryOption.allCases.last {
                            Divider().opacity(0.3)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, BaseStatTheme.Spacing.lg)
    }

    // MARK: - Navigation

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { i in
                Capsule()
                    .fill(i == page ? BaseStatTheme.primaryTeal : Color.white.opacity(0.25))
                    .frame(width: i == page ? 20 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: page)
            }
        }
        .padding(.top, BaseStatTheme.Spacing.md)
    }

    private var navigationButtons: some View {
        HStack(spacing: BaseStatTheme.Spacing.sm) {
            if page > 0 {
                Button {
                    withAnimation { page -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, height: 50)
                        .baseStatGlassButton(cornerRadius: 25)
                }
            }

            Button {
                handleNext()
            } label: {
                HStack {
                    Text(page == totalPages - 1 ? "Get Started" : "Continue")
                        .font(BaseStatTheme.Typography.bodySemibold)
                    if page < totalPages - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .baseStatGlassButton(cornerRadius: BaseStatTheme.Radius.pill)
            }
            .disabled(page == 1 && name.isEmpty)
        }
    }

    private func handleNext() {
        if page < totalPages - 1 {
            withAnimation { page += 1 }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        let engine = GamificationEngine.shared
        let profile = engine.fetchOrCreateProfile(context: context)
        profile.name = name.isEmpty ? "Athlete" : name
        profile.weightGoalKg = Double(goalWeight) ?? 70.0
        profile.weightUnit = weightUnit
        profile.onboardingComplete = true
        try? context.save()

        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.onboardingComplete)
        UserDefaults.standard.set(historyOption.rawValue, forKey: Constants.UserDefaultsKeys.healthHistoryDays)

        Task {
            try? await HealthKitManager.shared.requestAuthorization()
            engine.suppressPopups = true
            engine.batchUnlockedCount = 0
            await HealthKitManager.shared.importHealthHistory(days: historyOption.rawValue, context: context)
            await engine.checkPersonalRecords(context: context)
            engine.suppressPopups = false

            await NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleStreakReminder()

            engine.unlockAchievement(
                AchievementCatalog.all.first { $0.id == "meta.first_login" }!,
                context: context
            )
        }

        onComplete()
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    var icon: String
    var color: Color
    var title: String
    var subtitle: String

    var body: some View {
        HStack(spacing: BaseStatTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BaseStatTheme.Typography.bodySemibold)
                Text(subtitle)
                    .font(BaseStatTheme.Typography.small)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct HealthPermissionRow: View {
    var icon: String
    var color: Color
    var label: String

    var body: some View {
        HStack(spacing: BaseStatTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(label)
                .font(BaseStatTheme.Typography.body)
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.green.opacity(0.7))
        }
    }
}
