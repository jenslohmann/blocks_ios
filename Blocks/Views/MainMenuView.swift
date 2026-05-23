import SwiftUI

/// The first screen the player sees. Navigates to Play, High Scores, How to Play, and About.
struct MainMenuView: View {

    @State private var navigateTo: AppScreen? = nil

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.051, green: 0.051, blue: 0.102)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App title
                Text(String(localized: "menu.title"))
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 8)

                Text(String(localized: "menu.subtitle"))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 48)

                // Menu buttons
                VStack(spacing: 16) {
                    MenuButton(
                        title: String(localized: "menu.play.button"),
                        systemImage: "play.fill",
                        color: .cyan
                    ) {
                        navigateTo = .game
                    }

                    MenuButton(
                        title: String(localized: "menu.highScores.button"),
                        systemImage: "trophy.fill",
                        color: .yellow
                    ) {
                        navigateTo = .highScores
                    }

                    MenuButton(
                        title: String(localized: "menu.howToPlay.button"),
                        systemImage: "questionmark.circle.fill",
                        color: .green
                    ) {
                        navigateTo = .howToPlay
                    }

                    MenuButton(
                        title: String(localized: "menu.about.button"),
                        systemImage: "info.circle.fill",
                        color: .purple
                    ) {
                        navigateTo = .about
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
        }
        .fullScreenCover(item: $navigateTo) { screen in
            switch screen {
            case .game:
                GameView()
            case .highScores:
                HighScoreView(isPresented: Binding(
                    get: { navigateTo == .highScores },
                    set: { if !$0 { navigateTo = nil } }
                ))
            case .howToPlay:
                HowToPlayView(isPresented: Binding(
                    get: { navigateTo == .howToPlay },
                    set: { if !$0 { navigateTo = nil } }
                ))
            case .about:
                AboutView(isPresented: Binding(
                    get: { navigateTo == .about },
                    set: { if !$0 { navigateTo = nil } }
                ))
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Menu button

private struct MenuButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 28)

                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AppScreen enum

enum AppScreen: Identifiable {
    case game, highScores, howToPlay, about

    var id: Self { self }
}

