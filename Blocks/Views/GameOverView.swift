import SwiftUI

/// Full-screen overlay shown when the game ends.
/// Displays the final score, the all-time high score, and a "Play Again" button.
/// Shows a "New Best!" badge when the player has set a new high score.
struct GameOverView: View {

    let score: Int
    let highScore: Int
    let isNewHighScore: Bool
    let onPlayAgain: () -> Void

    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                titleSection
                scoreSection
                playAgainButton
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.09, green: 0.09, blue: 0.18))
                    .shadow(color: .black.opacity(0.5), radius: 24, y: 8)
            )
            .padding(.horizontal, 32)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .onAppear {
                withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                    cardScale = 1
                    cardOpacity = 1
                }
            }
        }
    }

    // MARK: - Sub-views

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(String(localized: "gameOver.title"))
                .font(.system(.largeTitle, design: .rounded, weight: .black))
                .foregroundStyle(.white)

            if isNewHighScore {
                Text(String(localized: "gameOver.newHighScore.badge"))
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color.yellow)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var scoreSection: some View {
        VStack(spacing: 16) {
            scoreRow(
                label: String(localized: "gameOver.finalScore.label"),
                value: score,
                valueColor: .white
            )
            Divider().background(Color.white.opacity(0.15))
            scoreRow(
                label: String(localized: "game.highScore.label"),
                value: highScore,
                valueColor: .yellow
            )
        }
    }

    private func scoreRow(label: String, value: Int, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.formatted())
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(valueColor)
        }
    }

    private var playAgainButton: some View {
        Button(action: onPlayAgain) {
            Text(String(localized: "gameOver.playAgain.button"))
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                )
        }
    }
}
