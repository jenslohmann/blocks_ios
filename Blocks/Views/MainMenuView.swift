import SwiftUI

/// The first screen the player sees. Navigates to Play, High Scores, How to Play, and About.
struct MainMenuView: View {

    @State private var navigateTo: AppScreen? = nil
    @State private var showThemePicker: Bool = false
    @AppStorage("appTheme") private var appTheme: String = AppTheme.dark.rawValue

    var body: some View {
        ZStack {
            // Adaptive background
            Color("appBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Settings button — top right
                HStack {
                    Spacer()
                    Button(action: { showThemePicker = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .padding(16)
                    }
                }

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
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 48)

                // Menu buttons
                VStack(spacing: 16) {
                    MenuButton(title: String(localized: "menu.play.button"),       systemImage: "play.fill",              color: .cyan)   { navigateTo = .game }
                    MenuButton(title: String(localized: "menu.highScores.button"), systemImage: "trophy.fill",            color: .yellow) { navigateTo = .highScores }
                    MenuButton(title: String(localized: "menu.howToPlay.button"),  systemImage: "questionmark.circle.fill", color: .green) { navigateTo = .howToPlay }
                    MenuButton(title: String(localized: "menu.about.button"),      systemImage: "info.circle.fill",       color: .purple) { navigateTo = .about }
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
        .sheet(isPresented: $showThemePicker) {
            ThemePickerSheet(appTheme: $appTheme)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
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
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
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
