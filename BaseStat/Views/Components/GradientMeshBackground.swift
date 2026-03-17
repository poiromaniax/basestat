import SwiftUI

struct GradientMeshBackground: View {
    var colors: [Color] = BaseStatTheme.dashboardMeshColors
    var animates: Bool = true

    @State private var phase: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: !animates)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedPoints(time: timeline.date.timeIntervalSinceReferenceDate),
                colors: colors
            )
            .ignoresSafeArea()
        }
    }

    private func animatedPoints(time: Double) -> [SIMD2<Float>] {
        let phase = Float(time) * 0.15
        return [
            [0.0, 0.0], [0.5 + 0.05 * sin(phase), 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + 0.04 * cos(phase * 1.1), 0.5 + 0.04 * sin(phase * 0.9)], [1.0, 0.5],
            [0.0, 1.0], [0.5 + 0.05 * sin(phase * 0.8), 1.0], [1.0, 1.0]
        ]
    }
}

struct StaticMeshBackground: View {
    var colors: [Color] = BaseStatTheme.dashboardMeshColors

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: colors
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientMeshBackground()
}
