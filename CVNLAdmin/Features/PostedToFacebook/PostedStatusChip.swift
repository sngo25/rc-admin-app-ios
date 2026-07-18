import SwiftUI

/// Status label shown on each Facebook post card.
struct PostedStatusChip: View {
    let status: PageFeedStatus

    var body: some View {
        Text(status.label)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .frame(height: 20)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var backgroundColor: Color {
        switch status {
        case .posted:
            return AdminTheme.successBackground
        case .scheduled:
            return AdminTheme.warningBackground
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .posted:
            return AdminTheme.successForeground
        case .scheduled:
            return AdminTheme.warningForeground
        }
    }
}
