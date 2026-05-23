/// The three appearance modes the player can choose from.
enum AppTheme: String, CaseIterable, Identifiable {
    case dark   = "dark"
    case light  = "light"
    case system = "system"

    var id: String { rawValue }
}

