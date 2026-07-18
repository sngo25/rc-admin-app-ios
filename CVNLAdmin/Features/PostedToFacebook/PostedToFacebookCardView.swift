import SwiftUI

/// Single Facebook page post card matching the Posted to Facebook mock.
struct PostedToFacebookCardView: View {
    let item: PageFeedItem
    let onViewOnPage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
                .padding(.bottom, 8)

            if !item.bodyText.isEmpty {
                Text(item.bodyText)
                    .font(.system(size: 14))
                    .foregroundStyle(AdminTheme.textPrimary)
                    .tracking(-0.1)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if item.hasPermalink {
                cardFooter
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

    private var cardHeader: some View {
        HStack(spacing: 8) {
            if let confessionTag = item.confessionTag {
                Text(confessionTag)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AdminTheme.primary)
                    .padding(.horizontal, 8)
                    .frame(height: 22)
                    .background(AdminTheme.ackAllBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            if !item.isPublished {
                PostedStatusChip(status: item.status)
            }

            Spacer(minLength: 0)

            Text(item.postedAtText)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(AdminTheme.textTertiary)
        }
    }

    private var cardFooter: some View {
        HStack {
            Spacer(minLength: 0)

            ViewOnPageButton(action: onViewOnPage)
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AdminTheme.cardDivider)
                .frame(height: 1)
        }
    }
}
