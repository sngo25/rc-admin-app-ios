import SwiftUI

/// Offset pagination controls: Back / page / Go / Next (Confession list mockup).
struct ConfessionPaginationBar: View {
    /// 1-based page shown in the text field.
    @Binding var pageInput: String
    let currentPage: Int
    let totalPages: Int
    let onBack: () -> Void
    let onNext: () -> Void
    let onGo: () -> Void

    private var canGoBack: Bool {
        currentPage > 1
    }

    private var canGoNext: Bool {
        currentPage < totalPages
    }

    var body: some View {
        HStack(spacing: 8) {
            pagerButton(title: "Back", enabled: canGoBack, action: onBack)

            HStack(spacing: 7) {
                TextField("1", text: $pageInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(AdminTheme.textPrimary)
                    .frame(width: 42, height: 34)
                    .background(AdminTheme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(AdminTheme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 9))

                Text("/ \(max(totalPages, 1))")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(AdminTheme.textTertiary)
                    .lineLimit(1)

                Button(action: onGo) {
                    Text("Go")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(AdminTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(ConfessionPrimaryPressStyle(pressed: AdminTheme.primaryPressed))
            }
            .frame(maxWidth: .infinity)

            pagerButton(title: "Next", enabled: canGoNext, action: onNext)
        }
    }

    private func pagerButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: enabled ? .semibold : .medium))
                .foregroundStyle(enabled ? AdminTheme.iconMuted : AdminTheme.pagerDisabledText)
                .padding(.horizontal, 16)
                .frame(height: 34)
                .background(enabled ? AdminTheme.background : AdminTheme.settingsCancelBackground)
                .overlay {
                    if enabled {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AdminTheme.border, lineWidth: 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Light press feedback for solid primary buttons.
struct ConfessionPrimaryPressStyle: ButtonStyle {
    let pressed: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.92 : 1)
            .overlay {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(pressed.opacity(0.35))
                }
            }
    }
}
