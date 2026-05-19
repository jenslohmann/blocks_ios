import SwiftUI

/// Renders the 8×8 game board.
/// Cell size is computed dynamically from the available space so the board
/// fills the available square on every device and orientation.
/// An optional ghost piece is overlaid at the given origin to preview placement.
/// Cells in `clearingCells` play a flash-and-shrink animation before disappearing.
struct BoardView: View {

    let grid: [[String?]]
    var ghostPiece: Piece? = nil
    var ghostOrigin: Coordinate? = nil
    /// Coordinates of cells currently playing the clear animation.
    var clearingCells: Set<Coordinate> = []

    /// Exposes the board's frame in global coordinates so GameView can
    /// convert drag positions into board cell coordinates.
    var onFrameChanged: ((_ globalFrame: CGRect) -> Void)? = nil

    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(Board.size)
            let boardSize = cellSize * CGFloat(Board.size)

            ZStack(alignment: .topLeading) {
                // Grid cells
                VStack(spacing: 0) {
                    ForEach(0 ..< Board.size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0 ..< Board.size, id: \.self) { col in
                                CellView(
                                    colorName: grid[row][col],
                                    size: cellSize,
                                    isClearing: clearingCells.contains(Coordinate(row: row, col: col))
                                )
                            }
                        }
                    }
                }

                // Ghost overlay
                if let piece = ghostPiece, let origin = ghostOrigin {
                    ForEach(piece.cells, id: \.self) { cell in
                        let row = origin.row + cell.row
                        let col = origin.col + cell.col
                        RoundedRectangle(cornerRadius: cellSize * 0.15)
                            .fill(Color(piece.colorName).opacity(0.4))
                            .frame(width: cellSize, height: cellSize)
                            .offset(
                                x: CGFloat(col) * cellSize,
                                y: CGFloat(row) * cellSize
                            )
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .background(Color.white.opacity(0.03))
            .cornerRadius(8)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .background(
                GeometryReader { boardGeometry in
                    Color.clear
                        .onAppear {
                            onFrameChanged?(boardGeometry.frame(in: .global))
                        }
                        .onChange(of: boardGeometry.frame(in: .global)) { _, newFrame in
                            onFrameChanged?(newFrame)
                        }
                }
            )
        }
    }
}
