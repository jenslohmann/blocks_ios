/// A catalogue of every available piece shape.
/// Each shape is defined as an array of coordinates relative to the top-left origin (0, 0).
/// Pieces cannot be rotated — what you see in the library is what the player gets.
enum PieceLibrary {

    // MARK: - Block colors

    static let colorNames: [String] = [
        "pieceRed",
        "pieceOrange",
        "pieceYellow",
        "pieceGreen",
        "pieceCyan",
        "pieceBlue",
        "piecePurple"
    ]

    // MARK: - All shapes

    /// Returns every piece shape definition in the library.
    static let allShapes: [[Coordinate]] = [
        // Single
        [c(0,0)],

        // Dominoes
        [c(0,0), c(0,1)],
        [c(0,0), c(1,0)],

        // L-piece
        [c(0,0), c(1,0), c(2,0), c(2,1)],

        // J-piece
        [c(0,1), c(1,1), c(2,0), c(2,1)],

        // T-piece
        [c(0,0), c(0,1), c(0,2), c(1,1)],

        // S-piece
        [c(0,1), c(0,2), c(1,0), c(1,1)],

        // Z-piece
        [c(0,0), c(0,1), c(1,1), c(1,2)],

        // 2×2 Square
        [c(0,0), c(0,1), c(1,0), c(1,1)],

        // 3×3 Square
        [c(0,0), c(0,1), c(0,2),
         c(1,0), c(1,1), c(1,2),
         c(2,0), c(2,1), c(2,2)],

        // I-3 horizontal
        [c(0,0), c(0,1), c(0,2)],

        // I-4 horizontal
        [c(0,0), c(0,1), c(0,2), c(0,3)],

        // I-5 horizontal
        [c(0,0), c(0,1), c(0,2), c(0,3), c(0,4)],

        // I-3 vertical
        [c(0,0), c(1,0), c(2,0)],

        // I-4 vertical
        [c(0,0), c(1,0), c(2,0), c(3,0)],

        // I-5 vertical
        [c(0,0), c(1,0), c(2,0), c(3,0), c(4,0)]
    ]

    // MARK: - Random generation

    /// Returns a new set of 3 randomly chosen pieces, each with a random color.
    static func randomSet() -> [Piece] {
        var usedColorIndices: [Int] = []
        return (0 ..< 3).map { _ in
            let shape = allShapes.randomElement()!
            // Pick a color not already used in this set where possible
            var colorIndex = Int.random(in: 0 ..< colorNames.count)
            if usedColorIndices.count < colorNames.count {
                while usedColorIndices.contains(colorIndex) {
                    colorIndex = Int.random(in: 0 ..< colorNames.count)
                }
            }
            usedColorIndices.append(colorIndex)
            return Piece(cells: shape, colorName: colorNames[colorIndex])
        }
    }

    // MARK: - Private helper

    /// Shorthand for building a Coordinate — keeps shape definitions concise.
    private static func c(_ row: Int, _ col: Int) -> Coordinate {
        Coordinate(row: row, col: col)
    }
}

