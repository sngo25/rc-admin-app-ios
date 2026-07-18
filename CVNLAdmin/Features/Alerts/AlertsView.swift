import SwiftUI
import UIKit

/// Alerts & notifications screen backed by rc-admin-server APIs.
struct AlertsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminToast.self) private var toast

    let user: AdminUser
    let onMenuTap: () -> Void

    @State private var alerts: [AlertItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            AdminTopBar(
                title: "Alerts & notifications",
                userInitial: userInitial,
                onMenuTap: onMenuTap
            )

            AlertsSummaryBar(
                unacknowledgedCount: unacknowledgedCount,
                onAcknowledgeAll: acknowledgeAll
            )

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AdminTheme.screenBackground)
        .task {
            await loadAlerts()
        }
        .onReceive(NotificationCenter.default.publisher(for: .adminAlertReceived)) { _ in
            Task {
                await loadAlerts(showLoading: false)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await loadAlerts(showLoading: false)
            }
        }
        .onChange(of: unacknowledgedCount) { _, newCount in
            Task {
                await AppBadgeManager.sync(count: newCount)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            ErrorStateView(title: "Could not load alerts", message: errorMessage) {
                Task {
                    await loadAlerts()
                }
            }
        } else if sortedAlerts.isEmpty {
            emptyState
        } else {
            alertList
        }
    }

    private var userInitial: String {
        let trimmed = user.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else {
            return "?"
        }

        return String(first).uppercased()
    }

    private var unacknowledgedCount: Int {
        alerts.filter { !$0.isAcknowledged }.count
    }

    private var sortedAlerts: [AlertItem] {
        alerts.sorted {
            let left = $0.sortKey()
            let right = $1.sortKey()
            if left.0 != right.0 {
                return left.0 < right.0
            }

            return left.1 > right.1
        }
    }

    private var alertList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedAlerts) { alert in
                    AlertCardView(alert: alert) {
                        Task {
                            await acknowledge(alertID: alert.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Text("All caught up")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.emptyTitle)

            Text("No alerts need attention.")
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
    }

    private func loadAlerts(showLoading: Bool = true) async {
        if showLoading {
            isLoading = true
        }
        errorMessage = nil

        do {
            alerts = try await authManager.alertsAPI.listAlerts()
            isLoading = false
        } catch {
            isLoading = false
            // Soft refresh: keep stale list and toast. Cold load / empty: full-screen error.
            if !showLoading && !alerts.isEmpty {
                toast.show(error.userFacingMessage)
            } else {
                errorMessage = error.userFacingMessage
            }
        }
    }

    private func acknowledge(alertID: String) async {
        do {
            let updated = try await authManager.alertsAPI.acknowledge(alertID: alertID)
            replaceAlert(updated)
        } catch {
            // Never route mutation failures into load errorMessage (that wipes the list).
            toast.show(error.userFacingMessage)
        }
    }

    private func acknowledgeAll() {
        Task {
            do {
                alerts = try await authManager.alertsAPI.acknowledgeAll()
            } catch {
                toast.show(error.userFacingMessage)
            }
        }
    }

    private func replaceAlert(_ updated: AlertItem) {
        alerts = alerts.map { alert in
            alert.id == updated.id ? updated : alert
        }
    }
}
