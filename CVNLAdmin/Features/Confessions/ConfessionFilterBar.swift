import SwiftUI

/// Status filter dropdown + reload button (Confession list mockup).
struct ConfessionFilterBar: View {
    @Binding var filter: ConfessionFilter
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(ConfessionFilter.allCases, id: \.self) { option in
                    Button {
                        filter = option
                    } label: {
                        if option == filter {
                            Label(option.label, systemImage: "checkmark")
                        } else {
                            Text(option.label)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(filter.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AdminTheme.textPrimary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AdminTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(AdminTheme.filterBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AdminTheme.primary)
                    .frame(width: 34, height: 34)
                    .background(AdminTheme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AdminTheme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reload confessions")
        }
    }
}
