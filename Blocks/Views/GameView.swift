import SwiftUI

/// Root game screen.
///
/// Layout strategy driven entirely by size classes — no hard-coded sizes:
///
/// | horizontalSizeClass | verticalSizeClass | Result                      |
/// |---------------------|-------------------|-----------------------------|
/// | compact             | any               | iPhone portrait layout      |
/// | regular             | regular           | iPad portrait/landscape     |
/// | regular             | compact           | iPhone landscape layout     |
///
/// Within the iPad path, the actual orientation is derived from the
/// GeometryReader's aspect ratio so we can flank the HUD on wide screens.
struct GameView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass)   private var verticalSizeClass
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = GameViewModel()

    /// Board frame in global coordinates — updated by BoardView on every layout pass.
    @State private var boardGlobalFrame: CGRect = .zero

    // MARK: - Local animation state
    @State private var boardShakeOffset: CGFloat = 0
    @State private var scoreScale: CGFloat = 1
    @State private var scoreGlowAmount: CGFloat = 0
    @State private var showQuitConfirmation: Bool = false

    var body: some View {
        ZStack {
            // Background fills the whole screen including safe areas.
            Color(red: 0.051, green: 0.051, blue: 0.102)
                .ignoresSafeArea()

            GeometryReader { geometry in
                layoutBody(for: geometry)
            }

            // Back-to-menu button — top left corner.
            VStack {
                HStack {
                    Button(action: {
                        if viewModel.gameState.isGameOver {
                            dismiss()
                        } else {
                            showQuitConfirmation = true
                        }
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(12)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 8)

            // Game-over overlay always sits on top.
            if viewModel.gameState.isGameOver {
                GameOverView(
                    score: viewModel.gameState.score,
                    highScore: viewModel.gameState.highScore,
                    isNewHighScore: viewModel.gameState.isNewHighScore,
                    onPlayAgain: { viewModel.newGame() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState.isGameOver)
        .confirmationDialog(
            String(localized: "game.quit.title"),
            isPresented: $showQuitConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "game.quit.confirm"), role: .destructive) { dismiss() }
            Button(String(localized: "game.quit.cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "game.quit.message"))
        }
        // Combo: score label bounces with a gold glow.
        .onChange(of: viewModel.comboEventID) { _, _ in
            withAnimation(.spring(duration: 0.25)) { scoreScale = 1.35; scoreGlowAmount = 1 }
            withAnimation(.spring(duration: 0.25).delay(0.25)) { scoreScale = 1; scoreGlowAmount = 0 }
        }
        // Game over: board shakes horizontally.
        .onChange(of: viewModel.gameOverEventID) { _, _ in
            playBoardShake()
        }
    }

    // MARK: - Layout selector

    @ViewBuilder
    private func layoutBody(for geometry: GeometryProxy) -> some View {
        if horizontalSizeClass == .compact {
            // Compact width: iPhone portrait OR iPad in Split View / Slide Over.
            iPhonePortraitLayout(geometry: geometry)
        } else if verticalSizeClass == .compact {
            // Regular width + compact height: iPhone landscape.
            iPhoneLandscapeLayout(geometry: geometry)
        } else {
            // Regular width + regular height: native iPad.
            if geometry.size.width > geometry.size.height {
                iPadLandscapeLayout(geometry: geometry)
            } else {
                iPadPortraitLayout(geometry: geometry)
            }
        }
    }

    // MARK: - iPhone portrait
    // Board centred, tray below, HUD above.

    private func iPhonePortraitLayout(geometry: GeometryProxy) -> some View {
        let boardSide = min(geometry.size.width - 16, geometry.size.height * 0.6)
        let cellSize  = boardSide / CGFloat(Board.size)

        return VStack(spacing: 0) {
            animatedHUD
                .padding(.top, 52)  // clears the top-left back button
                .padding(.bottom, 8)

            boardView(cellSize: cellSize)
                .frame(width: boardSide, height: boardSide)
                .padding(.horizontal, 8)

            Spacer(minLength: 0)

            tray(cellSize: cellSize * 0.62)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
    }

    // MARK: - iPhone landscape
    // Board left/centre, tray to the right, HUD at top.

    private func iPhoneLandscapeLayout(geometry: GeometryProxy) -> some View {
        let boardSide = min(geometry.size.height - 8, geometry.size.width * 0.55)
        let cellSize  = boardSide / CGFloat(Board.size)
        let trayCellSize = cellSize * 0.55

        return HStack(spacing: 0) {
            VStack(spacing: 0) {
                animatedHUD
                    .padding(.top, 52)  // clears the top-left back button
                    .padding(.bottom, 8)
                boardView(cellSize: cellSize)
                    .frame(width: boardSide, height: boardSide)
            }
            .frame(maxWidth: .infinity)

            // Tray stacked vertically on the right side.
            VStack(spacing: 0) {
                Spacer()
                verticalTray(cellSize: trayCellSize)
                Spacer()
            }
            .frame(width: geometry.size.width * 0.3)
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - iPad portrait
    // Board centred with generous padding, tray below, HUD above.

    private func iPadPortraitLayout(geometry: GeometryProxy) -> some View {
        let horizontalPadding: CGFloat = 60
        let boardSide = min(geometry.size.width - horizontalPadding * 2,
                            geometry.size.height * 0.62)
        let cellSize = boardSide / CGFloat(Board.size)

        return VStack(spacing: 0) {
            animatedHUD
                .padding(.top, 56)  // clears the top-left back button
                .padding(.bottom, 16)

            boardView(cellSize: cellSize)
                .frame(width: boardSide, height: boardSide)

            Spacer(minLength: 0)

            tray(cellSize: cellSize * 0.62)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 40)
        }
    }

    // MARK: - iPad landscape
    // Board centred, tray below, HUD flanking both sides.

    private func iPadLandscapeLayout(geometry: GeometryProxy) -> some View {
        let hudWidth: CGFloat = 140
        let boardSide = min(geometry.size.width - hudWidth * 2 - 32,
                            geometry.size.height * 0.78)
        let cellSize = boardSide / CGFloat(Board.size)
        let hud = HUDView(score: viewModel.gameState.score,
                          highScore: viewModel.gameState.highScore)

        return HStack(spacing: 0) {
            // Left HUD column — score
            VStack {
                Spacer()
                hud.scoreColumn(
                    label: String(localized: "game.score.label"),
                    value: viewModel.gameState.score
                )
                .scaleEffect(scoreScale)
                .shadow(color: .yellow.opacity(scoreGlowAmount * 0.8), radius: 12)
                Spacer()
            }
            .frame(width: hudWidth)

            // Centre: board + tray
            VStack(spacing: 0) {
                Spacer(minLength: 16)
                boardView(cellSize: cellSize)
                    .frame(width: boardSide, height: boardSide)
                Spacer(minLength: 0)
                tray(cellSize: cellSize * 0.62)
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)

            // Right HUD column — high score
            VStack {
                Spacer()
                hud.scoreColumn(
                    label: String(localized: "game.highScore.label"),
                    value: viewModel.gameState.highScore
                )
                Spacer()
            }
            .frame(width: hudWidth)
        }
    }

    // MARK: - Shared sub-views

    /// HUD view with combo bounce + gold glow animation applied.
    private var animatedHUD: some View {
        HUDView(score: viewModel.gameState.score,
                highScore: viewModel.gameState.highScore)
            .scaleEffect(scoreScale)
            .shadow(color: .yellow.opacity(scoreGlowAmount * 0.8), radius: 12)
    }

    private func boardView(cellSize: CGFloat) -> some View {
        BoardView(
            grid: viewModel.board.grid,
            ghostPiece: viewModel.draggedPiece,
            ghostOrigin: viewModel.ghostOrigin,
            clearingCells: viewModel.recentlyClearedCells,
            onFrameChanged: { frame in boardGlobalFrame = frame }
        )
        .offset(x: boardShakeOffset)
    }

    private func tray(cellSize: CGFloat) -> some View {
        PieceTrayView(
            slots: viewModel.pieceSet.slots,
            cellSize: cellSize,
            invalidDropEventID: viewModel.invalidDropEventID,
            onDragChanged: handleDragChanged,
            onDragEnded: handleDragEnded
        )
    }

    /// Vertical tray used in iPhone landscape — pieces stacked top-to-bottom.
    private func verticalTray(cellSize: CGFloat) -> some View {
        VStack(spacing: 20) {
            ForEach(0 ..< viewModel.pieceSet.slots.count, id: \.self) { index in
                if let piece = viewModel.pieceSet.slots[index] {
                    PieceView(
                        piece: piece,
                        cellSize: cellSize,
                        triggerInvalidDrop: viewModel.invalidDropEventID,
                        onDragChanged: { location in
                            handleDragChanged(piece: piece, globalLocation: location)
                        },
                        onDragEnded: { location in
                            handleDragEnded(piece: piece, globalLocation: location)
                        }
                    )
                } else {
                    Color.clear.frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }

    /// Horizontal shake animation — used on game over.
    private func playBoardShake() {
        let shakeDistance: CGFloat = 12
        withAnimation(.easeInOut(duration: 0.07))                 { boardShakeOffset =  shakeDistance }
        withAnimation(.easeInOut(duration: 0.07).delay(0.07))     { boardShakeOffset = -shakeDistance }
        withAnimation(.easeInOut(duration: 0.07).delay(0.14))     { boardShakeOffset =  shakeDistance * 0.6 }
        withAnimation(.easeInOut(duration: 0.07).delay(0.21))     { boardShakeOffset = -shakeDistance * 0.6 }
        withAnimation(.easeInOut(duration: 0.07).delay(0.28))     { boardShakeOffset = 0 }
    }

    // MARK: - Drag coordinate translation

    private func handleDragChanged(piece: Piece, globalLocation: CGPoint) {
        let cell = boardCell(for: globalLocation, piece: piece)
        viewModel.updateDrag(piece: piece, hoveredCell: cell)
    }

    private func handleDragEnded(piece: Piece, globalLocation: CGPoint?) {
        guard let globalLocation = globalLocation else {
            viewModel.cancelDrag()
            return
        }
        let cell = boardCell(for: globalLocation, piece: piece)
        viewModel.commitDrop(piece: piece, at: cell)
    }

    /// Converts a global drag point to a board Coordinate.
    /// Uses the board's reported global frame so translation is accurate on all
    /// device sizes and orientations, including iPad and Split View.
    private func boardCell(for globalPoint: CGPoint, piece: Piece) -> Coordinate? {
        guard boardGlobalFrame != .zero else { return nil }

        let cellSize = boardGlobalFrame.width / CGFloat(Board.size)
        let localX = globalPoint.x - boardGlobalFrame.minX
        let localY = globalPoint.y - boardGlobalFrame.minY

        let col = Int(localX / cellSize)
        let row = Int(localY / cellSize)

        let origin = Coordinate(row: row, col: col)
        for cell in piece.cells {
            let r = origin.row + cell.row
            let c = origin.col + cell.col
            if r < 0 || r >= Board.size || c < 0 || c >= Board.size { return nil }
        }
        return origin
    }
}


