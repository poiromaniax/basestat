import SwiftUI
import SwiftData

struct ChallengesView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ChallengesViewModel()
    @State private var showTemplates = false

    var body: some View {
        NavigationStack {
            ZStack {
                StaticMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

                ScrollView {
                    LazyVStack(spacing: BaseStatTheme.Spacing.md) {
                        if viewModel.activeChallenges.isEmpty && viewModel.completedChallenges.isEmpty {
                            emptyState
                        } else {
                            if !viewModel.activeChallenges.isEmpty {
                                sectionHeader("Active Challenges", count: viewModel.activeChallenges.count)
                                ForEach(viewModel.activeChallenges, id: \.id) { challenge in
                                    ChallengeCardView(challenge: challenge) {
                                        viewModel.abandonChallenge(challenge, context: context)
                                    }
                                }
                            }

                            if !viewModel.completedChallenges.isEmpty {
                                sectionHeader("Completed", count: viewModel.completedChallenges.count)
                                ForEach(viewModel.completedChallenges, id: \.id) { challenge in
                                    ChallengeCardView(challenge: challenge)
                                }
                            }

                            if !viewModel.expiredChallenges.isEmpty {
                                sectionHeader("Expired", count: viewModel.expiredChallenges.count)
                                ForEach(viewModel.expiredChallenges, id: \.id) { challenge in
                                    ChallengeCardView(challenge: challenge)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, BaseStatTheme.Spacing.md)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showTemplates = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showTemplates) {
                ChallengeTemplatesSheet(viewModel: viewModel) {
                    showTemplates = false
                    viewModel.load(context: context)
                }
                .presentationBackground(.clear)
                .presentationDetents([.large])
            }
            .onAppear { viewModel.load(context: context) }
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()
            Spacer()
            Text("\(count)")
                .font(BaseStatTheme.Typography.small)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, BaseStatTheme.Spacing.sm)
    }

    private var emptyState: some View {
        GlassCard(cornerRadius: BaseStatTheme.Radius.lg) {
            VStack(spacing: BaseStatTheme.Spacing.md) {
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.system(size: 48))
                    .foregroundStyle(.tertiary)
                Text("No Active Challenges")
                    .font(BaseStatTheme.Typography.title3)
                    .foregroundStyle(.primary)
                Text("Start a challenge to earn bonus XP and push your limits.")
                    .font(BaseStatTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    showTemplates = true
                } label: {
                    Label("Browse Challenges", systemImage: "plus")
                        .font(BaseStatTheme.Typography.bodySemibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .baseStatGlassButton(cornerRadius: BaseStatTheme.Radius.pill)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BaseStatTheme.Spacing.xl)
        }
        .padding(.top, BaseStatTheme.Spacing.xl)
    }
}

// MARK: - Templates Sheet

struct ChallengeTemplatesSheet: View {
    var viewModel: ChallengesViewModel
    var onDismiss: () -> Void
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                StaticMeshBackground(colors: BaseStatTheme.dashboardMeshColors)

                ScrollView {
                    LazyVStack(spacing: BaseStatTheme.Spacing.sm) {
                        if viewModel.availableTemplates.isEmpty {
                            GlassCard(cornerRadius: BaseStatTheme.Radius.md) {
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.green)
                                    Text("All challenges active!")
                                        .font(BaseStatTheme.Typography.bodySemibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            }
                        } else {
                            ForEach(viewModel.availableTemplates, id: \.title) { template in
                                ChallengeTemplateCard(template: template) {
                                    viewModel.startChallenge(template, context: context)
                                    onDismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, BaseStatTheme.Spacing.md)
                    .padding(.bottom, BaseStatTheme.Spacing.xxl)
                }
            }
            .navigationTitle("Start a Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDismiss)
                }
            }
        }
    }
}
