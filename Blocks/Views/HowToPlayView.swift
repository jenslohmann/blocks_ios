import SwiftUI

/// Step-by-step tutorial screen explaining the game rules.
/// Presented as a full-screen cover from the main menu.
struct HowToPlayView: View {

    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color(red: 0.051, green: 0.051, blue: 0.102)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader(
                    title: String(localized: "howToPlay.title"),
                    onClose: { isPresented = false }
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        TutorialStep(
                            number: 1,
                            icon: "hand.draw.fill",
                            color: .cyan,
                            heading: String(localized: "howToPlay.step1.heading"),
                            bodyText: String(localized: "howToPlay.step1.body")
                        )

                        TutorialStep(
                            number: 2,
                            icon: "rectangle.3.group.fill",
                            color: .green,
                            heading: String(localized: "howToPlay.step2.heading"),
                            bodyText: String(localized: "howToPlay.step2.body")
                        )

                        TutorialStep(
                            number: 3,
                            icon: "sparkles",
                            color: .yellow,
                            heading: String(localized: "howToPlay.step3.heading"),
                            bodyText: String(localized: "howToPlay.step3.body")
                        )

                        TutorialStep(
                            number: 4,
                            icon: "flame.fill",
                            color: .orange,
                            heading: String(localized: "howToPlay.step4.heading"),
                            bodyText: String(localized: "howToPlay.step4.body")
                        )

                        TutorialStep(
                            number: 5,
                            icon: "xmark.octagon.fill",
                            color: .red,
                            heading: String(localized: "howToPlay.step5.heading"),
                            bodyText: String(localized: "howToPlay.step5.body")
                        )

                        // Scoring table
                        scoringSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Scoring table

    private var scoringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "howToPlay.scoring.heading"))
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 8) {
                ScoringRow(action: String(localized: "howToPlay.scoring.placePiece"),  points: String(localized: "howToPlay.scoring.placePiece.pts"))
                ScoringRow(action: String(localized: "howToPlay.scoring.clear1"),      points: "10 pts")
                ScoringRow(action: String(localized: "howToPlay.scoring.clear2"),      points: "30 pts")
                ScoringRow(action: String(localized: "howToPlay.scoring.clear3"),      points: "60 pts")
                ScoringRow(action: String(localized: "howToPlay.scoring.clear4"),      points: "100 pts")
                ScoringRow(action: String(localized: "howToPlay.scoring.combo"),       points: "×1.5")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.06))
            )
        }
    }
}

// MARK: - Sub-views

private struct TutorialStep: View {
    let number: Int
    let icon: String
    let color: Color
    let heading: String
    let bodyText: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(heading)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(bodyText)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct ScoringRow: View {
    let action: String
    let points: String

    var body: some View {
        HStack {
            Text(action)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text(points)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.yellow)
        }
    }
}
