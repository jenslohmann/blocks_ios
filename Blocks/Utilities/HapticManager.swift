import UIKit
/// Centralises all haptic feedback so the rest of the app never references
/// UIKit feedback generators directly. All methods are called on the main thread.
@MainActor
enum HapticManager {
    static func piecePlaced() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func lineCleared() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func combo() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    static func gameOver() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func invalidDrop() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
