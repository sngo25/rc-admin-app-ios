import SwiftUI

/// Summary row below the top bar: unacked count chip and optional "Acknowledge all".
struct AlertsSummaryBar: View {
    let unacknowledgedCount: Int
    let onAcknowledgeAll: () -> Void

    private var hasUnacknowledged: Bool {
        unacknowledgedCount > 0
    }

    private var chipLabel: String {
        if hasUnacknowledged {
            return "\(unacknowledgedCount) unacknowledged"
        }

        return "All acknowledged"
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(chipLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(chipForeground)
                .padding(.horizontal, 10)
                .frame(height: 26)
                .background(chipBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()

            if hasUnacknowledged {
                Button(action: onAcknowledgeAll) {
                    Text("Acknowledge all")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AdminTheme.primary)
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(AdminTheme.ackAllBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(AcknowledgeAllButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AdminTheme.background)
        .overlay(alignment: .bottom) {
            Divider()
                .overlay(AdminTheme.divider)
        }
    }

    private var chipBackground: Color {
        hasUnacknowledged ? AdminTheme.warningBackground : AdminTheme.successBackground
    }

    private var chipForeground: Color {
        hasUnacknowledged ? AdminTheme.warningForeground : AdminTheme.successForeground
    }
}

/// Pressed state for the light-purple "Acknowledge all" button.
private struct AcknowledgeAllButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? AdminTheme.ackAllBackgroundPressed : AdminTheme.ackAllBackground)
            .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}
