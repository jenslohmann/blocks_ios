import Foundation

/// A game piece made up of one or more cells arranged in a specific shape.
/// Cells are expressed as coordinates relative to the piece's top-left origin (0, 0).
/// Pieces cannot be rotated.
struct Piece: Identifiable {
    let id: UUID
    let cells: [Coordinate]
    let colorName: String

    init(cells: [Coordinate], colorName: String) {
        self.id = UUID()
        self.cells = cells
        self.colorName = colorName
    }
}

