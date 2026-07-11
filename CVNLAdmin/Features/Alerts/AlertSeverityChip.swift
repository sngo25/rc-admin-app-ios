import SwiftUI

/// Colored severity label shown at the top of each alert card.
struct AlertSeverityChip: View {
    let severity: AlertSeverity

    var body: some View {
        Text(severity.label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var backgroundColor: Color {
        switch severity {
        case .critical:
            return AdminTheme.criticalBackground
        case .warning:
            return AdminTheme.warningBackground
        case .info:
            return AdminTheme.infoBackground
        }
    }

    private var foregroundColor: Color {
        switch severity {
        case .critical:
            return AdminTheme.criticalForeground
        case .warning:
            return AdminTheme.warningForeground
        case .info:
            return AdminTheme.infoForeground
        }
    }
}
