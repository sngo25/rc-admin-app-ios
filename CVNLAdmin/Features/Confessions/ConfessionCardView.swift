import SwiftUI

/// Single confession card: number chip, timestamp, body, status-specific footer.
struct ConfessionCardView: View {
    let item: ConfessionItem
    let onApprove: () -> Void
    let onReject: () -> Void
    let onSaveNumber: (Int) -> Void
    let onPostToFacebook: () -> Void

    @State private var isEditingNumber = false
    @State private var numberDraft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
                .padding(.bottom, 10)

            Text(item.content)
                .font(.system(size: 15))
                .foregroundStyle(AdminTheme.confessionBody)
                .tracking(-0.1)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            footer
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
            numberChip

            Button {
                toggleEditNumber()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AdminTheme.textTertiary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit confession number")

            Spacer(minLength: 0)

            Text(item.createdAtText)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(AdminTheme.textTertiary)
        }
    }

    private var numberChip: some View {
        HStack(spacing: 0) {
            Text("#")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(AdminTheme.primary)

            if isEditingNumber {
                TextField("", text: $numberDraft)
                    .keyboardType(.numberPad)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(AdminTheme.primary)
                    .frame(width: 52, height: 20)
                    .onSubmit {
                        commitNumberEdit()
                    }
            } else {
                Text(item.numberDisplay)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(AdminTheme.primary)
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 4)
        .frame(height: 22)
        .background(AdminTheme.ackAllBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private var footer: some View {
        switch item.status {
        case .pending:
            pendingActions
                .padding(.top, 14)

        case .approved:
            approvedFooter
                .padding(.top, 14)

        case .rejected:
            rejectedFooter
                .padding(.top, 14)
        }
    }

    private var pendingActions: some View {
        HStack(spacing: 8) {
            Button(action: onReject) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Reject")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(AdminTheme.criticalForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(AdminTheme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AdminTheme.rejectBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button(action: onApprove) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                    Text("Approve")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(AdminTheme.successForeground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(ConfessionPrimaryPressStyle(pressed: AdminTheme.approveGreenPressed))
        }
    }

    private var approvedFooter: some View {
        HStack(spacing: 8) {
            ConfessionStatusChip(kind: .approved)

            if item.canPostToFacebook {
                ConfessionPostButton(action: onPostToFacebook)
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AdminTheme.cardDivider)
                .frame(height: 1)
        }
    }

    private var rejectedFooter: some View {
        HStack {
            ConfessionStatusChip(kind: .rejected)
            Spacer(minLength: 0)
        }
        .padding(.top, 12)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AdminTheme.cardDivider)
                .frame(height: 1)
        }
    }

    private func toggleEditNumber() {
        if isEditingNumber {
            commitNumberEdit()
        } else {
            numberDraft = item.numberDisplay
            isEditingNumber = true
        }
    }

    private func commitNumberEdit() {
        isEditingNumber = false
        let parsed = Int(numberDraft.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        guard parsed != item.number else {
            return
        }

        onSaveNumber(parsed)
    }
}
