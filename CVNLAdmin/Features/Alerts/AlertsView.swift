import SwiftUI
import UIKit

/// Alerts & notifications screen backed by rc-admin-server APIs.
struct AlertsView: View {
    @Environment(AuthManager.self) private var authManager

    let user: AdminUser
    let onLogout: () async -> Void

    @State private var alerts: [AlertItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isMenuPresented = false

    var body: some View {
        VStack(spacing: 0) {
            AdminTopBar(
                title: "Alerts & notifications",
                userInitial: userInitial,
                onMenuTap: { isMenuPresented = true }
            )

            AlertsSummaryBar(
                unacknowledgedCount: unacknowledgedCount,
                onAcknowledgeAll: acknowledgeAll
            )

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AdminTheme.screenBackground)
        .sheet(isPresented: $isMenuPresented) {
            AdminMenuSheet(onLogout: onLogout)
        }
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
            errorState(message: errorMessage)
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

    private func errorState(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Could not load alerts")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.emptyTitle)

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textTertiary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task {
                    await loadAlerts()
                }
            }
            .buttonStyle(.borderedProminent)
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
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func acknowledge(alertID: String) async {
        do {
            let updated = try await authManager.alertsAPI.acknowledge(alertID: alertID)
            replaceAlert(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func acknowledgeAll() {
        Task {
            do {
                alerts = try await authManager.alertsAPI.acknowledgeAll()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func replaceAlert(_ updated: AlertItem) {
        alerts = alerts.map { alert in
            alert.id == updated.id ? updated : alert
        }
    }
}

/// Temporary menu sheet until a full navigation drawer is designed.
private struct AdminMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onLogout: () async -> Void

    var body: some View {
        NavigationStack {
            List {
                Button(role: .destructive) {
                    dismiss()
                    Task {
                        await onLogout()
                    }
                } label: {
                    Text("Logout")
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
