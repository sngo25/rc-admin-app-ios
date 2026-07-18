import SwiftUI

/// Approved / Rejected status chip shown on confession card footers.
struct ConfessionStatusChip: View {
    enum Kind {
        case approved
        case rejected
    }

    let kind: Kind

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: kind == .approved ? "checkmark" : "xmark")
                .font(.system(size: 11, weight: .semibold))

            Text(kind == .approved ? "Approved" : "Rejected")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 9)
        .frame(height: 26)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private var background: Color {
        switch kind {
        case .approved:
            return AdminTheme.successBackground
        case .rejected:
            return AdminTheme.criticalBackground
        }
    }

    private var foreground: Color {
        switch kind {
        case .approved:
            return AdminTheme.successForeground
        case .rejected:
            return AdminTheme.criticalForeground
        }
    }
}
