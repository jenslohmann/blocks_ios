import SwiftUI

/// Root game screen. Reads size class environment values to choose
/// the appropriate layout for the current device and orientation.
/// Owns the ViewModel and translates drag coordinates into board cells.
struct GameView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel = GameViewModel()

    /// The board's current frame in global coordinates.
    /// Updated by BoardView whenever it lays out.
    @State private var boardGlobalFrame: CGRect = .zero

    var body: some View {
        ZStack {
            Color(red: 0.051, green: 0.051, blue: 0.102)
                .ignoresSafeArea()

            if horizontalSizeClass == .compact {
                iPhoneLayout
            } else {
                iPadLayout
            }
        }
    }

    // MARK: - Layouts

    private var iPhoneLayout: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width - 16, geometry.size.height) / CGFloat(Board.size)
            VStack(spacing: 16) {
                HUDView(score: viewModel.gameState.score,
                        highScore: viewModel.gameState.highScore)
                boardView(cellSize: cellSize)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 8)
                Spacer()
                PieceTrayView(
                    slots: viewModel.pieceSet.slots,
                    cellSize: cellSize * 0.65,
                    onDragChanged: handleDragChanged,
                    onDragEnded: handleDragEnded
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
    }

    private var iPadLayout: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 120
            let cellSize = min(availableWidth, geometry.size.height * 0.7) / CGFloat(Board.size)
            VStack(spacing: 24) {
                HUDView(score: viewModel.gameState.score,
                        highScore: viewModel.gameState.highScore)
                boardView(cellSize: cellSize)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 60)
                Spacer()
                PieceTrayView(
                    slots: viewModel.pieceSet.slots,
                    cellSize: cellSize * 0.65,
                    onDragChanged: handleDragChanged,
                    onDragEnded: handleDragEnded
                )
                .padding(.horizontal, 60)
                .padding(.bottom, 32)
            }
            .padding(.top, 32)
        }
    }

    // MARK: - Board sub-view

    private func boardView(cellSize: CGFloat) -> some View {
        BoardView(
            grid: viewModel.board.grid,
            ghostPiece: viewModel.draggedPiece,
            ghostOrigin: viewModel.ghostOrigin,
            onFrameChanged: { frame in
                boardGlobalFrame = frame
            }
        )
    }

    // MARK: - Drag coordinate translation

    /// Converts a global drag location into the board cell that the top-left corner
    /// of the piece would occupy, then tells the ViewModel to update the ghost.
    private func handleDragChanged(piece: Piece, globalLocation: CGPoint) {
        let cell = boardCell(for: globalLocation, piece: piece)
        viewModel.updateDrag(piece: piece, hoveredCell: cell)
    }

    /// On drag end, attempt to commit the placement. The ViewModel returns false
    /// if the drop is invalid. (Wiggle animation added in M5.)
    private func handleDragEnded(piece: Piece, globalLocation: CGPoint?) {
        guard let globalLocation = globalLocation else {
            viewModel.cancelDrag()
            return
        }
        let cell = boardCell(for: globalLocation, piece: piece)
        viewModel.commitDrop(piece: piece, at: cell)
    }

    /// Translates a global point into a board Coordinate (row, col).
    /// Returns nil when the point is outside the board.
    private func boardCell(for globalPoint: CGPoint, piece: Piece) -> Coordinate? {
        guard boardGlobalFrame != .zero else { return nil }

        let cellSize = boardGlobalFrame.width / CGFloat(Board.size)

        // Offset so the piece's top-left corner leads the drag rather than its centre.
        let localX = globalPoint.x - boardGlobalFrame.minX
        let localY = globalPoint.y - boardGlobalFrame.minY

        let col = Int(localX / cellSize)
        let row = Int(localY / cellSize)

        // Validate that the entire piece would stay within bounds.
        let origin = Coordinate(row: row, col: col)
        for cell in piece.cells {
            let r = origin.row + cell.row
            let c = origin.col + cell.col
            if r < 0 || r >= Board.size || c < 0 || c >= Board.size { return nil }
        }
        return origin
    }
}
