import SwiftUI

/// Renders a single cell on the board.
/// If a color name is provided the cell is filled; otherwise it shows the empty grid style.
/// When `isClearing` is true the cell plays a flash-white then shrink-to-zero animation.
struct CellView: View {

    let colorName: String?
    let size: CGFloat
    var isClearing: Bool = false

    @State private var flashOpacity: Double = 0
    @State private var scale: CGFloat = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(fillColor)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.15)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                )

            // White flash overlay — animates in then out during a line clear.
            if isClearing {
                RoundedRectangle(cornerRadius: size * 0.15)
                    .fill(Color.white.opacity(flashOpacity))
                    .frame(width: size, height: size)
            }
        }
        .scaleEffect(scale)
        .onChange(of: isClearing) { _, clearing in
            if clearing {
                playClearAnimation()
            } else {
                // Reset for the next clear.
                flashOpacity = 0
                scale = 1
            }
        }
    }

    private var fillColor: Color {
        if let name = colorName {
            return Color(name)
        }
        return Color.primary.opacity(0.05)
    }

    private func playClearAnimation() {
        // Step 1: flash white.
        withAnimation(.easeIn(duration: 0.08)) {
            flashOpacity = 1
        }
        // Step 2: fade the flash out and shrink to nothing.
        withAnimation(.easeOut(duration: 0.22).delay(0.08)) {
            flashOpacity = 0
            scale = 0.01
        }
    }
}
