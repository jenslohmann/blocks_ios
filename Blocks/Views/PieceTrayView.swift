import SwiftUI

/// Displays the three piece slots in a horizontal row.
/// Nil slots render as empty space so the tray layout stays stable as pieces are placed.
struct PieceTrayView: View {

    let slots: [Piece?]
    let cellSize: CGFloat
    /// Toggled by GameView when an invalid drop occurs — triggers wiggle on each piece.
    var invalidDropEventID: UUID = UUID()
    var onDragChanged: ((_ piece: Piece, _ globalLocation: CGPoint) -> Void)? = nil
    var onDragEnded: ((_ piece: Piece, _ globalLocation: CGPoint?) -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< slots.count, id: \.self) { index in
                slotView(for: slots[index])
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func slotView(for piece: Piece?) -> some View {
        if let piece = piece {
            PieceView(
                piece: piece,
                cellSize: cellSize,
                triggerInvalidDrop: invalidDropEventID,
                onDragChanged: { location in
                    onDragChanged?(piece, location)
                },
                onDragEnded: { location in
                    onDragEnded?(piece, location)
                }
            )
        } else {
            Color.clear
                .frame(minWidth: 44, minHeight: 44)
        }
    }
}

