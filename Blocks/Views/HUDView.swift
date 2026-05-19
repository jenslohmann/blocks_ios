import SwiftUI
/// Displays the current score and the all-time high score.
struct HUDView: View {
    let score: Int
    let highScore: Int
    var body: some View {
        HStack {
            scoreColumn(label: String(localized: "game.score.label"), value: score)
            Spacer()
            scoreColumn(label: String(localized: "game.highScore.label"), value: highScore)
        }
        .padding(.horizontal, 24)
    }
    private func scoreColumn(label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value.formatted())
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
    }
}
