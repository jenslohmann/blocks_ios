import SwiftUI
/// Renders a single cell on the board.
/// If a color name is provided the cell is filled; otherwise it shows the empty grid style.
struct CellView: View {
    let colorName: String?
    let size: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.15)
            .fill(fillColor)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.15)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }
    private var fillColor: Color {
        if let name = colorName {
            return Color(name)
        }
        return Color.white.opacity(0.05)
    }
}
