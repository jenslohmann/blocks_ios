import SwiftUI
@main
struct BlocksApp: App {

    @AppStorage("appTheme") private var appTheme: String = AppTheme.dark.rawValue

    private var preferredColorScheme: ColorScheme? {
        switch AppTheme(rawValue: appTheme) {
        case .dark:   return .dark
        case .light:  return .light
        case .system, .none: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .preferredColorScheme(preferredColorScheme)
        }
    }
}
