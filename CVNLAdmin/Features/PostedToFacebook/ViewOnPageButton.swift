import SwiftUI

/// Opens the Facebook permalink for a page post.
struct ViewOnPageButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text("View on page")
                    .font(.system(size: 12, weight: .semibold))

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(AdminTheme.primary)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(AdminTheme.ackAllBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ViewOnPageButtonStyle())
    }
}

/// Pressed state for the light-purple View on page button.
private struct ViewOnPageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? AdminTheme.ackAllBackgroundPressed
                    : AdminTheme.ackAllBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
