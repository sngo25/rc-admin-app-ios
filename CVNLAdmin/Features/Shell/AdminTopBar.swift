import SwiftUI

/// Shared top bar used across post-login admin screens.
/// Matches the design mock: hamburger menu, screen title, settings gear, user avatar.
struct AdminTopBar: View {
    let title: String
    let userInitial: String
    let onMenuTap: () -> Void

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
                .buttonStyle(IconButtonStyle())

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AdminTheme.textPrimary)
                    .tracking(-0.3)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
                .buttonStyle(IconButtonStyle())
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
        .fullScreenCover(isPresented: $isSettingsPresented) {
            PostingSettingsSheet(store: PostingSettingsStore.shared) {
                isSettingsPresented = false
            }
            .presentationBackground(.clear)
        }
    }
}

/// Subtle press feedback for icon-only top bar buttons.
private struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? AdminTheme.iconButtonHover : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
