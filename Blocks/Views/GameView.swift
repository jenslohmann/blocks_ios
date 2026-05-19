import SwiftUI
/// Root game screen. Reads size class environment values to choose
/// the appropriate layout for the current device and orientation.
struct GameView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    // A placeholder board for M1 — the ViewModel wires this up in M2.
    @State private var board = Board()
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.051, green: 0.051, blue: 0.102)
                .ignoresSafeArea()
            if horizontalSizeClass == .compact {
                iPhonePortraitLayout
            } else {
                iPadLayout
            }
        }
    }
    // MARK: - Layouts
    private var iPhonePortraitLayout: some View {
        VStack(spacing: 16) {
            HUDView(score: 0, highScore: 0)
            BoardView(grid: board.grid)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 8)
            Spacer()
        }
        .padding(.top, 16)
    }
    private var iPadLayout: some View {
        VStack(spacing: 24) {
            HUDView(score: 0, highScore: 0)
            BoardView(grid: board.grid)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 60)
            Spacer()
        }
        .padding(.top, 32)
    }
}
