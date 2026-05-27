import SwiftUI

/// Displays the all-time top-10 scores, each with its date, stored via ScoreRepository.
/// Presented as a full-screen cover from the main menu.
struct HighScoreView: View {

    @Binding var isPresented: Bool

    private let entries: [ScoreEntry] = ScoreRepository.loadTopScores()

    var body: some View {
        ZStack {
            Color("appBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader(
                    title: String(localized: "highScore.title"),
                    onClose: { isPresented = false }
                )

                if entries.isEmpty {
                    emptyState
                } else {
                    scoreList
                }
            }
        }
    }

    // MARK: - Sub-views

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                )
            Text(String(localized: "highScore.noScoreYet"))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Spacer()
        }
    }

    private var scoreList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    ScoreRow(rank: index + 1, entry: entry)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
}

// MARK: - ScoreRow

private struct ScoreRow: View {
    let rank: Int
    let entry: ScoreEntry

    /// Medal colour for the top three positions.
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            Text("\(rank)")
                .font(.system(.headline, design: .rounded).bold())
                .foregroundStyle(rankColor)
                .frame(width: 32, alignment: .center)

            // Score
            Text(entry.score.formatted())
                .font(.system(.title3, design: .rounded).bold())
                .foregroundStyle(.primary)
                .monospacedDigit()

            Spacer()

            // Date
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
