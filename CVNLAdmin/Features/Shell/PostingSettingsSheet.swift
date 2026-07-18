import SwiftUI

/// Posting settings dialog matching the Confession list mockup.
/// Edits local confession auto-post settings (count + interval); last posted time is read-only.
struct PostingSettingsSheet: View {
    let store: PostingSettingsStore
    let facebookAPI: FacebookAPI
    let onDismiss: () -> Void

    // Draft values so Cancel does not mutate the store.
    @State private var draftPostedCount: String = ""
    @State private var draftIntervalMinutes: String = ""
    @State private var isFetchingPostedCount = false
    @State private var fetchError: String?

    var body: some View {
        ZStack {
            // Dimmed + blurred backdrop (mockup: rgba(20,20,28,0.42) + blur).
            AdminTheme.settingsBackdrop
                .opacity(0.42)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(alignment: .leading, spacing: 0) {
                Text("Posting settings")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(AdminTheme.textPrimary)
                    .tracking(-0.4)

                Text("Control how confessions are auto-posted to the fan page.")
                    .font(.system(size: 13))
                    .foregroundStyle(AdminTheme.textSecondary)
                    .lineSpacing(2)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 16) {
                    // Posted count + explicit refresh so a stale local value can catch up to Facebook.
                    VStack(alignment: .leading, spacing: 6) {
                        settingsNumberField(
                            label: "Confessions posted so far",
                            text: $draftPostedCount,
                            isLoading: isFetchingPostedCount,
                            showsRefreshButton: true,
                            onRefresh: {
                                Task {
                                    await refreshPostedCountFromFacebook()
                                }
                            }
                        )

                        if let fetchError {
                            Text(fetchError)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AdminTheme.criticalForeground)
                        }
                    }

                    settingsNumberField(
                        label: "Interval between posts (minutes)",
                        text: $draftIntervalMinutes
                    )

                    // Read-only last-posted row (mockup shows display-only).
                    HStack {
                        Text("Last posted at")
                            .font(.system(size: 13))
                            .foregroundStyle(AdminTheme.emptyTitle)

                        Spacer()

                        Text(formattedLastPosted)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(AdminTheme.textPrimary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AdminTheme.screenBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 20)

                HStack(spacing: 10) {
                    Button(action: onDismiss) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AdminTheme.bodySecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(AdminTheme.settingsCancelBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(
                        SettingsActionButtonStyle(pressedBackground: AdminTheme.settingsCancelBackgroundPressed)
                    )

                    Button(action: save) {
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(AdminTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(SettingsActionButtonStyle(pressedBackground: AdminTheme.primaryPressed))
                    .disabled(isFetchingPostedCount)
                }
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
        .onAppear {
            // Seed drafts from the store when the dialog opens.
            draftPostedCount = String(store.postedCount)
            draftIntervalMinutes = String(store.intervalMinutes)
        }
        .task {
            await refetchPostedCountIfNeeded()
        }
    }

    private var formattedLastPosted: String {
        guard let lastPostedAt = store.lastPostedAt else {
            return "—"
        }
        return Self.lastPostedFormatter.string(from: lastPostedAt)
    }

    /// When local count is 0 or last-posted time is unset, pull both from recent Facebook posts.
    private func refetchPostedCountIfNeeded() async {
        guard store.postedCount == 0 || store.lastPostedAt == nil else {
            return
        }

        await refreshPostedCountFromFacebook(useBootstrap: true)
    }

    /// Force-sync from Facebook (Refresh button), or bootstrap-only when `useBootstrap` is true.
    private func refreshPostedCountFromFacebook(useBootstrap: Bool = false) async {
        isFetchingPostedCount = true
        fetchError = nil

        do {
            let count: Int
            if useBootstrap {
                count = try await store.ensurePostedCount(using: facebookAPI)
            } else {
                count = try await store.refreshPostedCount(using: facebookAPI)
            }
            draftPostedCount = String(count)
        } catch {
            // Keep the current draft so the admin can type manually.
            fetchError = "\(error.userFacingMessage) Enter the number manually."
        }

        isFetchingPostedCount = false
    }

    private func settingsNumberField(
        label: String,
        text: Binding<String>,
        isLoading: Bool = false,
        showsRefreshButton: Bool = false,
        onRefresh: (() -> Void)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AdminTheme.textSecondary)

            HStack(spacing: 8) {
                TextField("", text: text)
                    .keyboardType(.numberPad)
                    .font(.system(size: 15))
                    .foregroundStyle(AdminTheme.textPrimary)
                    .disabled(isLoading)

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else if showsRefreshButton, let onRefresh {
                    // Explicit refresh — only raises local count to Facebook max when tapped.
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AdminTheme.primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Refresh from Facebook")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(AdminTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(AdminTheme.border, lineWidth: 1)
            )
        }
    }

    private func save() {
        let count = Int(draftPostedCount) ?? store.postedCount
        let interval = Int(draftIntervalMinutes) ?? store.intervalMinutes
        store.save(postedCount: count, intervalMinutes: interval)
        onDismiss()
    }

    /// Matches mockup format: "Jul 11, 2026 · 15:50".
    private static let lastPostedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy · HH:mm"
        return formatter
    }()
}

/// Press feedback for Cancel / Save without changing label layout.
private struct SettingsActionButtonStyle: ButtonStyle {
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
