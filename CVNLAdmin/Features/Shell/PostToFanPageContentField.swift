import SwiftUI

/// Multiline post body editor with mockup placeholder for Post to fan page.
struct PostToFanPageContentField: View {
    @Binding var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Post content")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AdminTheme.textSecondary)

            TextEditor(text: $message)
                .font(.system(size: 14))
                .foregroundStyle(AdminTheme.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120, maxHeight: 160)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AdminTheme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(AdminTheme.border, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    // Placeholder when the editor is empty.
                    if message.isEmpty {
                        Text("Write or paste the confession here…")
                            .font(.system(size: 14))
                            .foregroundStyle(AdminTheme.textTertiary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}
