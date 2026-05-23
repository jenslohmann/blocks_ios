import SwiftUI

/// A bottom sheet that lets the player choose between Dark, Light, or System appearance.
struct ThemePickerSheet: View {

    @Binding var appTheme: String

    var body: some View {
        VStack(spacing: 0) {
            Text(String(localized: "settings.theme.title"))
                .font(.system(.headline, design: .rounded, weight: .bold))
                .padding(.top, 24)
                .padding(.bottom, 20)

            VStack(spacing: 0) {
                ThemeRow(
                    icon: "moon.fill",
                    label: String(localized: "settings.theme.dark"),
                    themeValue: AppTheme.dark.rawValue,
                    selectedTheme: $appTheme
                )
                Divider().padding(.leading, 56)
                ThemeRow(
                    icon: "sun.max.fill",
                    label: String(localized: "settings.theme.light"),
                    themeValue: AppTheme.light.rawValue,
                    selectedTheme: $appTheme
                )
                Divider().padding(.leading, 56)
                ThemeRow(
                    icon: "circle.lefthalf.filled",
                    label: String(localized: "settings.theme.system"),
                    themeValue: AppTheme.system.rawValue,
                    selectedTheme: $appTheme
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Row

private struct ThemeRow: View {
    let icon: String
    let label: String
    let themeValue: String
    @Binding var selectedTheme: String

    var isSelected: Bool { selectedTheme == themeValue }

    var body: some View {
        Button(action: { selectedTheme = themeValue }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 24)

                Text(label)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

