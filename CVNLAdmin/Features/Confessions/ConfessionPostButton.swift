import SwiftUI

/// Blue “Post to Facebook” CTA on approved confession cards.
struct ConfessionPostButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "f.circle.fill")
                    .font(.system(size: 13, weight: .semibold))

                Text("Post to Facebook")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(AdminTheme.facebookBlue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(ConfessionFacebookPressStyle())
    }
}

private struct ConfessionFacebookPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.92 : 1)
            .overlay {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AdminTheme.facebookBluePressed.opacity(0.4))
                }
            }
    }
}
