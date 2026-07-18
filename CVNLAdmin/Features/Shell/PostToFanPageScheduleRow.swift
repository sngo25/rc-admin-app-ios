import SwiftUI

/// Schedule checkbox + date picker row for the Post to fan page dialog.
struct PostToFanPageScheduleRow: View {
    @Binding var scheduleLater: Bool
    @Binding var publishDate: Date

    var body: some View {
        HStack(spacing: 12) {
            Button {
                scheduleLater.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(scheduleLater ? AdminTheme.primary : AdminTheme.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    scheduleLater ? AdminTheme.primary : AdminTheme.scheduleCheckboxBorder,
                                    lineWidth: 1
                                )
                        )

                    if scheduleLater {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Schedule for later")

            Text("Schedule for later")
                .font(.system(size: 14))
                .foregroundStyle(AdminTheme.scheduleCheckboxLabel)
                .onTapGesture {
                    scheduleLater.toggle()
                }

            DatePicker(
                "",
                selection: $publishDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .disabled(!scheduleLater)
            .opacity(scheduleLater ? 1 : 0.55)
            .tint(AdminTheme.primary)
        }
    }
}
