import SwiftUI

/// Full-screen load failure with retry. Used when a list has no usable data to keep on screen.
struct ErrorStateView: View {
    let title: String
    let message: String
    var retryTitle: String = "Retry"
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.emptyTitle)

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textTertiary)
                .multilineTextAlignment(.center)

            Button(retryTitle, action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
    }
}
