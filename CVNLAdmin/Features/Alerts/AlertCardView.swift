import SwiftUI

/// Single alert card with acknowledge CTA or acknowledged metadata.
struct AlertCardView: View {
    let alert: AlertItem
    let onAcknowledge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                AlertSeverityChip(severity: alert.severity)

                Spacer()

                Text(alert.time)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(AdminTheme.textTertiary)
            }
            .padding(.bottom, 8)

            Text(alert.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.textPrimary)
                .tracking(-0.1)

            Text(alert.message)
                .font(.system(size: 14))
                .foregroundStyle(AdminTheme.bodySecondary)
                .lineSpacing(3)
                .padding(.top, 6)

            if alert.isAcknowledged {
                acknowledgedFooter
            } else {
                acknowledgeButton
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(AdminTheme.background)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AdminTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
    }

    private var acknowledgeButton: some View {
        Button(action: onAcknowledge) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .semibold))

                Text("Acknowledge")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(AdminTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(AcknowledgeButtonStyle())
        .padding(.top, 12)
    }

    private var acknowledgedFooter: some View {
        HStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))

                Text("Acknowledged")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(AdminTheme.successForeground)
            .padding(.horizontal, 9)
            .frame(height: 26)
            .background(AdminTheme.successBackground)
            .clipShape(RoundedRectangle(cornerRadius: 7))

            if let acknowledgedBy = alert.acknowledgedBy, let acknowledgedAt = alert.acknowledgedAt {
                Text("by \(acknowledgedBy) · \(acknowledgedAt)")
                    .font(.system(size: 12))
                    .foregroundStyle(AdminTheme.textTertiary)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AdminTheme.cardDivider)
                .frame(height: 1)
        }
    }
}

/// Pressed state for the purple acknowledge button.
private struct AcknowledgeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? AdminTheme.primaryPressed : AdminTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
