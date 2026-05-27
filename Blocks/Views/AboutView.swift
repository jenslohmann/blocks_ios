import SwiftUI
import UIKit

/// About screen — app name, version, open-source info.
/// Presented as a full-screen cover from the main menu.
struct AboutView: View {

    @Binding var isPresented: Bool

    /// Reads the app icon from the bundle's CFBundleIcons entry.
    private var appIconImage: UIImage? {
        guard
            let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastName = iconFiles.last
        else { return nil }
        return UIImage(named: lastName)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var copyrightYear: String {
        let year = Calendar.current.component(.year, from: Date())
        return "© \(year) Jens Lohmann"
    }

    var body: some View {
        ZStack {
            Color("appBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader(
                    title: String(localized: "about.title"),
                    onClose: { isPresented = false }
                )

                Spacer()

                // App icon + name
                Group {
                    if let icon = appIconImage {
                        Image(uiImage: icon)
                            .resizable()
                            .scaledToFit()
                    } else {
                        // Fallback if icon cannot be read from bundle
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Text("B")
                                    .font(.system(size: 52, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            )
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.bottom, 20)

                Text(String(localized: "about.appName"))
                    .font(.system(.title, design: .rounded, weight: .black))
                    .foregroundStyle(.primary)

                Text(String(localized: "about.version \(appVersion)"))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .padding(.bottom, 40)

                // Open-source row
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.cyan)
                        Text(String(localized: "about.openSource.label"))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.primary)
                        Spacer()
                    }

                    Link(destination: URL(string: "https://github.com/jenslohmann/blocks_ios")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(.caption, design: .rounded))
                            Text("github.com/jenslohmann/blocks_ios")
                                .font(.system(.caption, design: .rounded))
                                .underline()
                        }
                        .foregroundStyle(.cyan.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 32)

                Spacer()

                // Copyright statement
                Text(copyrightYear)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .padding(.bottom, 40)
            }
        }

    }
}
