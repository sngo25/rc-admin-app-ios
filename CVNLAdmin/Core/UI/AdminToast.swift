import Observation
import SwiftUI

/// Shared non-blocking toast for mutation and soft-refresh failures.
/// Mount once on the authenticated shell and call `show` from feature screens.
@MainActor
@Observable
final class AdminToast {
    private(set) var message: String?
    private var dismissTask: Task<Void, Never>?

    /// Shows a message and auto-dismisses after a few seconds.
    func show(_ message: String) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        dismissTask?.cancel()
        self.message = trimmed

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else {
                return
            }
            self.message = nil
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        message = nil
    }
}

/// Top banner overlay driven by `AdminToast` in the environment.
struct AdminToastOverlayModifier: ViewModifier {
    @Environment(AdminToast.self) private var toast

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let message = toast.message {
                AdminToastBanner(message: message) {
                    toast.dismiss()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: toast.message)
    }
}

extension View {
    /// Renders the shared toast banner above this view hierarchy.
    func adminToastOverlay() -> some View {
        modifier(AdminToastOverlayModifier())
    }
}

/// Compact dismissible banner used by `AdminToast`.
private struct AdminToastBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AdminTheme.criticalForeground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
    }
}
