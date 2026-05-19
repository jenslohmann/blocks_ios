/// The 8×8 game board. Holds the grid state and exposes methods for
/// checking placement validity, placing pieces, and clearing completed lines.
///
/// Each cell stores the color name of the block occupying it, or nil if the cell is empty.
class Board {

    static let size = 8

    /// The grid of color names. A nil value means the cell is empty.
    /// Internal access allows unit tests to set up board state directly.
    var grid: [[String?]]

    init() {
        grid = Array(
            repeating: Array(repeating: nil, count: Board.size),
            count: Board.size
        )
    }

    // MARK: - Placement

    /// Returns true if every cell of the piece, offset by the given origin, lands
    /// within the grid bounds and on an empty cell.
    func canPlace(_ piece: Piece, at origin: Coordinate) -> Bool {
        for cell in piece.cells {
            let row = origin.row + cell.row
            let col = origin.col + cell.col

            let isWithinBounds = row >= 0 && row < Board.size && col >= 0 && col < Board.size
            guard isWithinBounds else { return false }

            let isCellEmpty = grid[row][col] == nil
            guard isCellEmpty else { return false }
        }
        return true
    }

    /// Places the piece on the board at the given origin.
    /// Each cell in the piece's shape is filled with the piece's color name.
    /// Assumes `canPlace(_:at:)` returned true for the same arguments.
    func place(_ piece: Piece, at origin: Coordinate) {
        for cell in piece.cells {
            let row = origin.row + cell.row
            let col = origin.col + cell.col
            grid[row][col] = piece.colorName
        }
    }

    // MARK: - Line Clearing

    /// Scans all rows and columns for completed lines, clears them simultaneously,
    /// and returns the total number of lines cleared.
    @discardableResult
    func clearFullLines() -> Int {
        let fullRows = (0 ..< Board.size).filter { row in
            grid[row].allSatisfy { $0 != nil }
        }

        let fullCols = (0 ..< Board.size).filter { col in
            (0 ..< Board.size).allSatisfy { row in grid[row][col] != nil }
        }

        for row in fullRows {
            for col in 0 ..< Board.size {
                grid[row][col] = nil
            }
        }

        for col in fullCols {
            for row in 0 ..< Board.size {
                grid[row][col] = nil
            }
        }

        return fullRows.count + fullCols.count
    }

    // MARK: - Helpers

    /// Returns the set of all cell coordinates that belong to completed rows or columns,
    /// without modifying the grid. Used to drive clear animations before `clearFullLines()`.
    func fullLineCells() -> Set<Coordinate> {
        var result = Set<Coordinate>()

        let fullRows = (0 ..< Board.size).filter { row in
            grid[row].allSatisfy { $0 != nil }
        }
        let fullCols = (0 ..< Board.size).filter { col in
            (0 ..< Board.size).allSatisfy { row in grid[row][col] != nil }
        }

        for row in fullRows {
            for col in 0 ..< Board.size {
                result.insert(Coordinate(row: row, col: col))
            }
        }
        for col in fullCols {
            for row in 0 ..< Board.size {
                result.insert(Coordinate(row: row, col: col))
            }
        }
        return result
    }

    /// Returns true if the piece can be placed at any valid position on the board.
    func hasValidPlacement(for piece: Piece) -> Bool {
        for row in 0 ..< Board.size {
            for col in 0 ..< Board.size {
                if canPlace(piece, at: Coordinate(row: row, col: col)) {
                    return true
                }
            }
        }
        return false
    }
}

