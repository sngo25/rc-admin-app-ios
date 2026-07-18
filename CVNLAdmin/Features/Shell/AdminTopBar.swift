import SwiftUI

/// Shared top bar used across post-login admin screens.
/// Matches the design mock: hamburger, title, compose, settings gear, user avatar.
struct AdminTopBar: View {
    @Environment(AuthManager.self) private var authManager

    let title: String
    let userInitial: String
    let onMenuTap: () -> Void

    @State private var isPostPresented = false
    @State private var isSettingsPresented = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onMenuTap) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AdminTheme.iconMuted)
                        .frame(width: 38, height: 38)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(IconButtonStyle(pressedBackground: AdminTheme.iconButtonHover))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AdminTheme.textPrimary)
                    .tracking(-0.3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Compose — opens Post to fan page (Confession list mockup).
                Button {
                    isPostPresented = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AdminTheme.primary)
                        .frame(width: 38, height: 38)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(IconButtonStyle(pressedBackground: AdminTheme.ackAllBackground))
                .accessibilityLabel("Post to fan page")

                // Settings gear — opens Posting settings (Confession list mockup).
                Button {
                    isSettingsPresented = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AdminTheme.iconMuted)
                        .frame(width: 38, height: 38)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(IconButtonStyle(pressedBackground: AdminTheme.iconButtonHover))
                .accessibilityLabel("Posting settings")

                Text(userInitial)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AdminTheme.primary)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Divider()
                .overlay(AdminTheme.divider)
        }
        .background(AdminTheme.background)
        .fullScreenCover(isPresented: $isPostPresented) {
            PostToFanPageSheet(
                facebookAPI: authManager.facebookAPI,
                store: PostingSettingsStore.shared
            ) {
                isPostPresented = false
            }
            .presentationBackground(.clear)
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            PostingSettingsSheet(
                store: PostingSettingsStore.shared,
                facebookAPI: authManager.facebookAPI
            ) {
                isSettingsPresented = false
            }
            .presentationBackground(.clear)
        }
    }
}

/// Subtle press feedback for icon-only top bar buttons.
private struct IconButtonStyle: ButtonStyle {
    let pressedBackground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedBackground : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
