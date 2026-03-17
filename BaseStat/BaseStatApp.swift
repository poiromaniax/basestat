import SwiftUI
import SwiftData

@main
struct BaseStatApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                UserProfile.self,
                HealthSnapshot.self,
                Achievement.self,
                Streak.self,
                Challenge.self,
                ActivityLog.self
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitContainerIdentifier: Constants.App.iCloudContainer
            )
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(container)
        }
    }
}

// MARK: - Root View (Onboarding vs Main App)

struct AppRootView: View {
    @Environment(\.modelContext) private var context
    @State private var onboardingComplete: Bool = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.onboardingComplete)

    var body: some View {
        Group {
            if onboardingComplete {
                MainTabView()
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingComplete = true
                    }
                }
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView()
            }
            Tab("Health", systemImage: "heart.text.clipboard.fill") {
                HealthDetailRootView()
            }
            Tab("Achievements", systemImage: "trophy.fill") {
                AchievementsGalleryView()
            }
            Tab("Challenges", systemImage: "flag.checkered.2.crossed") {
                ChallengesView()
            }
            Tab("Profile", systemImage: "person.fill") {
                ProfileView()
            }
        }
    }
}
