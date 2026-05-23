import SwiftUI

/// Displays the all-time high score stored in UserDefaults.
/// Presented as a full-screen cover from the main menu.
struct HighScoreView: View {

    @Binding var isPresented: Bool

    private let highScore: Int = UserDefaults.standard.integer(forKey: "highScore")

    var body: some View {
        ZStack {
            Color("appBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation bar
                screenHeader(
                    title: String(localized: "highScore.title"),
                    onClose: { isPresented = false }
                )

                Spacer()

                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.bottom, 24)

                // Score value
                Text(highScore.formatted())
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Text(String(localized: "highScore.pointsLabel"))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                if highScore == 0 {
                    Text(String(localized: "highScore.noScoreYet"))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                        .padding(.horizontal, 40)
                }

                Spacer()
                Spacer()
            }
        }

    }
}
