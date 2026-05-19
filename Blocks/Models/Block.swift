/// A single filled cell on the board.
/// The color is stored as a name string so Models stay free of SwiftUI imports.
struct Block: Hashable {
    let coordinate: Coordinate
    let colorName: String
}

