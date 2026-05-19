import SwiftUI
/// Renders the 8×8 game board.
/// Cell size is computed dynamically from the available space so the board
/// fills the available square on every device and orientation.
struct BoardView: View {
    let grid: [[String?]]
    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(Board.size)
            let boardSize = cellSize * CGFloat(Board.size)
            VStack(spacing: 0) {
                ForEach(0 ..< Board.size, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0 ..< Board.size, id: \.self) { col in
                            CellView(colorName: grid[row][col], size: cellSize)
                        }
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .background(Color.white.opacity(0.03))
            .cornerRadius(8)
            // Centre the board inside the GeometryReader frame
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
