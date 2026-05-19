import SwiftUI

/// Renders a single piece as a compact grid of coloured cells.
/// Exposes drag callbacks so the parent (PieceTrayView / GameView) can
/// translate the drag position into a board coordinate and show the ghost overlay.
/// Plays a wiggle animation when `triggerInvalidDrop` is toggled.
struct PieceView: View {

    let piece: Piece
    /// The size of each mini-cell inside the piece preview.
    let cellSize: CGFloat
    /// Toggle this to play the wiggle-back animation (invalid placement).
    var triggerInvalidDrop: UUID = UUID()
    /// Called every time the drag position changes; provides the global drag location.
    var onDragChanged: ((_ globalLocation: CGPoint) -> Void)? = nil
    /// Called when the drag ends; provides the final global location.
    var onDragEnded: ((_ globalLocation: CGPoint?) -> Void)? = nil

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var wiggleAngle: Double = 0

    var body: some View {
        pieceGrid
            .offset(dragOffset)
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .rotationEffect(.degrees(wiggleAngle))
            .animation(.spring(duration: 0.2), value: isDragging)
            .gesture(dragGesture)
            .onChange(of: triggerInvalidDrop) { _, _ in
                playWiggle()
            }
    }

    // MARK: - Piece grid

    private var pieceGrid: some View {
        let boundingRows = (piece.cells.map(\.row).max() ?? 0) + 1
        let boundingCols = (piece.cells.map(\.col).max() ?? 0) + 1
        let occupiedSet = Set(piece.cells)

        return VStack(spacing: 0) {
            ForEach(0 ..< boundingRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< boundingCols, id: \.self) { col in
                        let coordinate = Coordinate(row: row, col: col)
                        if occupiedSet.contains(coordinate) {
                            RoundedRectangle(cornerRadius: cellSize * 0.15)
                                .fill(Color(piece.colorName))
                                .frame(width: cellSize, height: cellSize)
                        } else {
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 44, minHeight: 44)
    }

    // MARK: - Drag gesture

    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                dragOffset = value.translation
                isDragging = true
                onDragChanged?(value.location)
            }
            .onEnded { value in
                dragOffset = .zero
                isDragging = false
                onDragEnded?(value.location)
            }
    }

    // MARK: - Wiggle animation

    private func playWiggle() {
        // Three quick left-right rotations, then snap back to 0.
        withAnimation(.easeInOut(duration: 0.07)) { wiggleAngle = -12 }
        withAnimation(.easeInOut(duration: 0.07).delay(0.07)) { wiggleAngle = 12 }
        withAnimation(.easeInOut(duration: 0.07).delay(0.14)) { wiggleAngle = -8 }
        withAnimation(.easeInOut(duration: 0.07).delay(0.21)) { wiggleAngle = 0 }
    }
}

