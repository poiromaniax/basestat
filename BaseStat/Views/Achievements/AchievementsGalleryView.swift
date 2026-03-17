import SwiftUI
import SwiftData

struct AchievementsGalleryView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = AchievementsViewModel()
    @State private var selectedDefinition: AchievementDefinition?

    private let columns = [GridItem(.adaptive(minimum: 90), spacing: BaseStatTheme.Spacing.md)]

    var body: some View {
        NavigationStack {
            ZStack {
                StaticMeshBackground(colors: BaseStatTheme.achievementMeshColors)

                ScrollView {
                    LazyVStack(spacing: BaseStatTheme.Spacing.lg, pinnedViews: .sectionHeaders) {
                        summaryCard
                        categoryFilter
                        achievementGrid
                    }
                    .padding(.horizontal, BaseStatTheme.Spacing.md)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedDefinition) { def in
                AchievementDetailSheet(
                    definition: def,
                    isUnlocked: viewModel.isUnlocked(def.id),
                    unlockedDate: viewModel.unlockedDate(for: def.id)
                )
                .presentationDetents([.medium])
                .presentationBackground(.clear)
            }
            .onAppear { viewModel.load(context: context) }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.lg) {
            HStack(spacing: BaseStatTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.totalUnlocked) / \(AchievementCatalog.all.count)")
                        .font(BaseStatTheme.Typography.title1)
                        .foregroundStyle(.primary)
                    Text("Achievements Unlocked")
                        .font(BaseStatTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                GlassProgressRing(
                    progress: viewModel.completionPercent,
                    lineWidth: 8,
                    size: 70,
                    color: BaseStatTheme.rarityLegendary,
                    label: "\(Int(viewModel.completionPercent * 100))%"
                )
            }
        }
        .padding(.top, BaseStatTheme.Spacing.md)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BaseStatTheme.Spacing.sm) {
                CategoryChip(
                    label: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: viewModel.selectedCategory == nil
                ) { viewModel.selectedCategory = nil }

                ForEach(AchievementCategory.allCases, id: \.self) { cat in
                    let unlocked = viewModel.unlockedByCategory[cat] ?? 0
                    let total    = viewModel.totalByCategory[cat] ?? 0
                    CategoryChip(
                        label: "\(cat.rawValue) \(unlocked)/\(total)",
                        icon: cat.icon,
                        isSelected: viewModel.selectedCategory == cat
                    ) { viewModel.selectedCategory = cat }
                }
            }
        }
    }

    // MARK: - Achievement Grid

    private var achievementGrid: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.lg, padding: BaseStatTheme.Spacing.md) {
            LazyVGrid(columns: columns, spacing: BaseStatTheme.Spacing.lg) {
                ForEach(viewModel.filtered) { def in
                    AchievementBadgeView(
                        definition: def,
                        isUnlocked: viewModel.isUnlocked(def.id),
                        unlockedDate: viewModel.unlockedDate(for: def.id)
                    )
                    .onTapGesture { selectedDefinition = def }
                }
            }
            .padding(.vertical, BaseStatTheme.Spacing.sm)
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    var label: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(BaseStatTheme.Typography.caption)
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                if isSelected {
                    Capsule()
                        .fill(BaseStatTheme.primaryTeal.opacity(0.4))
                        .glassEffect(.regular.interactive(), in: Capsule())
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .glassEffect(.regular.interactive(), in: Capsule())
                }
            }
        }
        .buttonStyle(.plain)
    }
}
