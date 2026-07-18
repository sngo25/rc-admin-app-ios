import SwiftUI

/// Post-to-fan-page dialog matching the Confession list mockup.
/// Publishes via POST /facebook/postToPage (same as rc-admin-web header button).
struct PostToFanPageSheet: View {
    let facebookAPI: FacebookAPI
    let store: PostingSettingsStore
    /// Prefills the post content (e.g. from an approved confession card).
    var initialMessage: String = ""
    let onDismiss: () -> Void

    @State private var message = ""
    @State private var scheduleLater = false
    @State private var publishDate = Date()
    @State private var isPublishing = false
    @State private var errorMessage: String?
    @State private var didSucceed = false
    @State private var didSeedMessage = false

    private var canPublish: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPublishing && !didSucceed
    }

    var body: some View {
        ZStack {
            // Dimmed + blurred backdrop (same as Posting settings).
            AdminTheme.settingsBackdrop
                .opacity(0.42)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isPublishing {
                        onDismiss()
                    }
                }

            dialogCard
        }
        .onAppear {
            seedInitialMessageIfNeeded()
            seedScheduleFromSettings()
        }
    }

    /// Apply card prefill once so edits are not overwritten.
    private func seedInitialMessageIfNeeded() {
        guard !didSeedMessage else {
            return
        }

        didSeedMessage = true
        if !initialMessage.isEmpty {
            message = initialMessage
        }
    }

    private var dialogCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Post to fan page")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(AdminTheme.textPrimary)
                .tracking(-0.4)

            Text("Double-check everything before you publish.")
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textSecondary)
                .lineSpacing(2)
                .padding(.top, 4)

            PostToFanPageContentField(message: $message)
                .padding(.top, 18)

            PostToFanPageScheduleRow(
                scheduleLater: $scheduleLater,
                publishDate: $publishDate
            )
            .padding(.top, 16)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AdminTheme.criticalForeground)
                    .padding(.top, 12)
            }

            if didSucceed {
                Text(scheduleLater ? "Scheduled!" : "Posted!")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AdminTheme.successForeground)
                    .padding(.top, 12)
            }

            actionButtons
                .padding(.top, 22)
        }
        .padding(22)
        .frame(maxWidth: 340)
        .background(AdminTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(
            color: Color(red: 15 / 255, green: 15 / 255, blue: 25 / 255).opacity(0.35),
            radius: 30,
            y: 12
        )
        .padding(.horizontal, 20)
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                if !isPublishing {
                    onDismiss()
                }
            } label: {
                Text("Cancel")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AdminTheme.bodySecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AdminTheme.settingsCancelBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(
                PostDialogActionButtonStyle(
                    pressedBackground: AdminTheme.settingsCancelBackgroundPressed
                )
            )
            .disabled(isPublishing)

            Button {
                Task { await publish() }
            } label: {
                Group {
                    if isPublishing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Publish")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(canPublish ? AdminTheme.primary : AdminTheme.primary.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(
                PostDialogActionButtonStyle(pressedBackground: AdminTheme.primaryPressed)
            )
            .disabled(!canPublish)
        }
    }

    /// Match web: if the next slot after lastPostedAt is still ahead, pre-check schedule.
    private func seedScheduleFromSettings() {
        if let suggested = store.suggestedScheduleDate {
            scheduleLater = true
            publishDate = suggested
        } else {
            scheduleLater = false
            publishDate = Date()
        }
    }

    private func publish() async {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        isPublishing = true
        errorMessage = nil

        // Web sends Unix seconds when scheduling; omit for immediate publish.
        let publishTimeSeconds: Int? = scheduleLater
            ? Int(ceil(publishDate.timeIntervalSince1970))
            : nil

        do {
            try await facebookAPI.postToPage(message: trimmed, publishTime: publishTimeSeconds)

            // Web updates lastPublishTime to scheduled ms or Date.now().
            let recordedAt = scheduleLater ? publishDate : Date()
            store.recordPublish(at: recordedAt)

            didSucceed = true
            try? await Task.sleep(for: .milliseconds(700))
            onDismiss()
        } catch {
            errorMessage = "Could not publish. Please try again."
            isPublishing = false
        }
    }
}

/// Press feedback for Cancel / Publish without changing label layout.
private struct PostDialogActionButtonStyle: ButtonStyle {
    let pressedBackground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.92 : 1)
            .overlay {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(pressedBackground.opacity(0.35))
                }
            }
    }
}
