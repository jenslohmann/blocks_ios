import SwiftUI

/// A reusable top navigation bar for secondary screens (High Score, How to Play, About).
/// Renders a centred title and a close/back button on the trailing side.
func screenHeader(title: String, onClose: @escaping () -> Void) -> some View {
    ZStack {
        Text(title)
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundStyle(.primary)

        HStack {
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }
    .padding(.horizontal, 16)
    .padding(.top, 16)
    .padding(.bottom, 8)
}

