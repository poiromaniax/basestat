import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var selectedHistory: Constants.HistoryOption = Constants.HistoryOption.saved
    @State private var journeyStartDate: Date = (UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.journeyStartDate) as? Date) ?? Date()
    @State private var notifStreakEnabled: Bool = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.notifStreakEnabled) as? Bool ?? true
    @State private var notifAchievementEnabled: Bool = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.notifAchievementEnabled) as? Bool ?? true
    @State private var notifLevelUpEnabled: Bool = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.notifLevelUpEnabled) as? Bool ?? true
    @State private var notifStreakHour: Int = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.notifStreakHour) as? Int ?? Constants.Notifications.streakReminderHour

    var body: some View {
        NavigationStack {
            ZStack {
                StaticMeshBackground(colors: BaseStatTheme.profileMeshColors)

                ScrollView {
                    LazyVStack(spacing: BaseStatTheme.Spacing.md) {
                        heroCard
                        statsGrid
                        streaksCard
                        recentActivityCard
                        healthSettingsCard
                        journeySettingsCard
                        notificationSettingsCard
                    }
                    .padding(.horizontal, BaseStatTheme.Spacing.md)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                if let profile = viewModel.profile {
                    EditProfileSheet(profile: profile) { name, goal, unit in
                        viewModel.updateProfile(name: name, weightGoal: goal, weightUnit: unit, context: context)
                        showEditProfile = false
                    }
                    .presentationDetents([.medium])
                    .presentationBackground(.clear)
                }
            }
            .onAppear { viewModel.load(context: context) }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.lg, padding: BaseStatTheme.Spacing.lg) {
            VStack(spacing: BaseStatTheme.Spacing.md) {
                if let profile = viewModel.profile {
                    LevelProgressRing(profile: profile, size: 100)

                    VStack(spacing: 4) {
                        Text(profile.name.isEmpty ? "Your Name" : profile.name)
                            .font(BaseStatTheme.Typography.title2)
                            .foregroundStyle(.primary)

                        Text(profile.levelTitle)
                            .font(BaseStatTheme.Typography.bodySemibold)
                            .foregroundStyle(BaseStatTheme.xpColor)

                        Text("Member since \(profile.joinDate.shortDate)")
                            .font(BaseStatTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    XPProgressBar(profile: profile, showLabel: true)
                        .padding(.top, 4)

                    HStack(spacing: BaseStatTheme.Spacing.xl) {
                        VStack(spacing: 2) {
                            Text("\(profile.totalXP)")
                                .font(BaseStatTheme.Typography.title3)
                                .foregroundStyle(BaseStatTheme.xpColor)
                            Text("Total XP")
                                .sectionHeaderStyle()
                        }
                        VStack(spacing: 2) {
                            Text("\(viewModel.unlockedAchievements)/\(viewModel.totalAchievements)")
                                .font(BaseStatTheme.Typography.title3)
                            Text("Badges")
                                .sectionHeaderStyle()
                        }
                        VStack(spacing: 2) {
                            Text("\(viewModel.totalWorkouts)")
                                .font(BaseStatTheme.Typography.title3)
                            Text("Workouts")
                                .sectionHeaderStyle()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, BaseStatTheme.Spacing.md)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BaseStatTheme.Spacing.sm) {
            if viewModel.weightLostKg > 0 {
                StatCard(
                    icon: "scalemass.fill",
                    color: .cyan,
                    title: "Weight Lost",
                    value: String(format: "%.1f kg", viewModel.weightLostKg)
                )
            }
            if let best = viewModel.longestStreak {
                StatCard(
                    icon: "flame.fill",
                    color: BaseStatTheme.fireColor,
                    title: "Longest Streak",
                    value: "\(best.longestCount) days"
                )
            }
            StatCard(
                icon: "dumbbell.fill",
                color: .green,
                title: "Workouts",
                value: "\(viewModel.totalWorkouts)"
            )
            if let profile = viewModel.profile {
                StatCard(
                    icon: "target",
                    color: .purple,
                    title: "Goal Weight",
                    value: "\(profile.weightGoalKg.asWeightString) \(profile.weightUnit)"
                )
            }
        }
    }

    // MARK: - Streaks Card

    private var streaksCard: some View {
        Group {
            if !viewModel.streaks.isEmpty {
                GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                    VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                        Text("All Streaks")
                            .sectionHeaderStyle()

                        ForEach(viewModel.streaks, id: \.type) { streak in
                            HStack(spacing: 10) {
                                Image(systemName: streak.type.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(streak.isActiveToday ? BaseStatTheme.fireColor : .secondary)
                                    .frame(width: 22)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(streak.type.rawValue)
                                        .font(BaseStatTheme.Typography.bodySemibold)
                                    Text("Best: \(streak.longestCount) days")
                                        .font(BaseStatTheme.Typography.small)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(streak.currentCount)")
                                        .font(BaseStatTheme.Typography.title3)
                                        .foregroundStyle(streak.isActiveToday ? .primary : .secondary)
                                    Text("days")
                                        .font(BaseStatTheme.Typography.small)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Health Settings Card

    private var healthSettingsCard: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                Text("Health History")
                    .sectionHeaderStyle()

                ForEach(Constants.HistoryOption.allCases) { option in
                    Button {
                        selectedHistory = option
                        UserDefaults.standard.set(option.rawValue, forKey: Constants.UserDefaultsKeys.healthHistoryDays)
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
                            if selectedHistory == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(BaseStatTheme.primaryTeal)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    if option != Constants.HistoryOption.allCases.last {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
    }

    // MARK: - Journey Settings Card

    private var journeySettingsCard: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                Text("Journey")
                    .sectionHeaderStyle()

                DatePicker(
                    "Start Date",
                    selection: $journeyStartDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .onChange(of: journeyStartDate) { _, date in
                    UserDefaults.standard.set(date, forKey: Constants.UserDefaultsKeys.journeyStartDate)
                }
                .font(BaseStatTheme.Typography.body)
            }
        }
    }

    // MARK: - Notification Settings Card

    private var notificationSettingsCard: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
            VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                Text("Notifications")
                    .sectionHeaderStyle()

                Toggle(isOn: $notifStreakEnabled) {
                    Label("Streak Reminder", systemImage: "flame.fill")
                }
                .onChange(of: notifStreakEnabled) { _, val in
                    UserDefaults.standard.set(val, forKey: Constants.UserDefaultsKeys.notifStreakEnabled)
                    if val {
                        NotificationManager.shared.scheduleStreakReminder(hour: notifStreakHour)
                    } else {
                        NotificationManager.shared.cancelStreakReminder()
                    }
                }

                if notifStreakEnabled {
                    Divider().opacity(0.3)
                    Stepper("Reminder at \(notifStreakHour):00", value: $notifStreakHour, in: 6...22)
                        .font(BaseStatTheme.Typography.body)
                        .onChange(of: notifStreakHour) { _, hour in
                            UserDefaults.standard.set(hour, forKey: Constants.UserDefaultsKeys.notifStreakHour)
                            NotificationManager.shared.scheduleStreakReminder(hour: hour)
                        }
                }

                Divider().opacity(0.3)

                Toggle(isOn: $notifAchievementEnabled) {
                    Label("Achievement Unlocks", systemImage: "trophy.fill")
                }
                .onChange(of: notifAchievementEnabled) { _, val in
                    UserDefaults.standard.set(val, forKey: Constants.UserDefaultsKeys.notifAchievementEnabled)
                }

                Divider().opacity(0.3)

                Toggle(isOn: $notifLevelUpEnabled) {
                    Label("Level Up", systemImage: "arrow.up.circle.fill")
                }
                .onChange(of: notifLevelUpEnabled) { _, val in
                    UserDefaults.standard.set(val, forKey: Constants.UserDefaultsKeys.notifLevelUpEnabled)
                }
            }
        }
    }

    private var recentActivityCard: some View {
        Group {
            if !viewModel.recentActivity.isEmpty {
                GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                    VStack(alignment: .leading, spacing: BaseStatTheme.Spacing.sm) {
                        Text("Recent Activity")
                            .sectionHeaderStyle()

                        ForEach(viewModel.recentActivity, id: \.id) { log in
                            HStack(spacing: 10) {
                                Image(systemName: log.type.icon)
                                    .font(.system(size: 13))
                                    .foregroundStyle(BaseStatTheme.xpColor)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(log.eventDescription)
                                        .font(BaseStatTheme.Typography.body)
                                        .foregroundStyle(.secondary)
                                    Text(log.timestamp.relativeString)
                                        .font(BaseStatTheme.Typography.small)
                                        .foregroundStyle(.tertiary)
                                }
                                Spacer()
                                Text(log.xpEarned.asXPString)
                                    .xpLabelStyle()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    var icon: String
    var color: Color
    var title: String
    var value: String

    var body: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.md, padding: BaseStatTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(value)
                    .font(BaseStatTheme.Typography.title3)
                    .foregroundStyle(.primary)
                Text(title)
                    .sectionHeaderStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    var profile: UserProfile
    var onSave: (String, Double, String) -> Void

    @State private var name: String
    @State private var goalWeight: String
    @State private var unit: String

    init(profile: UserProfile, onSave: @escaping (String, Double, String) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _name       = State(initialValue: profile.name)
        _goalWeight = State(initialValue: profile.weightGoalKg.asWeightString)
        _unit       = State(initialValue: profile.weightUnit)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                StaticMeshBackground(colors: BaseStatTheme.profileMeshColors)

                Form {
                    Section("Your Name") {
                        TextField("Name", text: $name)
                    }
                    Section("Weight Goal") {
                        TextField("Goal weight", text: $goalWeight)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $unit) {
                            Text("kg").tag("kg")
                            Text("lbs").tag("lbs")
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onSave(profile.name, profile.weightGoalKg, profile.weightUnit) }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(name, Double(goalWeight) ?? profile.weightGoalKg, unit)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
