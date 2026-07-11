import SwiftUI

/// Alerts & notifications screen backed by local sample data.
struct AlertsView: View {
    let user: AdminUser
    let onLogout: () async -> Void

    @State private var alerts = AlertSampleData.alerts()
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

            if sortedAlerts.isEmpty {
                emptyState
            } else {
                alertList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AdminTheme.screenBackground)
        .sheet(isPresented: $isMenuPresented) {
            AdminMenuSheet(onLogout: onLogout)
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

            return left.1 < right.1
        }
    }

    private var alertList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedAlerts) { alert in
                    AlertCardView(alert: alert) {
                        acknowledge(alertID: alert.id)
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

    private func acknowledge(alertID: Int) {
        alerts = alerts.map { alert in
            guard alert.id == alertID, !alert.isAcknowledged else {
                return alert
            }

            return acknowledgedCopy(of: alert)
        }
    }

    private func acknowledgeAll() {
        alerts = alerts.map { alert in
            guard !alert.isAcknowledged else {
                return alert
            }

            return acknowledgedCopy(of: alert)
        }
    }

    private func acknowledgedCopy(of alert: AlertItem) -> AlertItem {
        var updated = alert
        updated.isAcknowledged = true
        updated.acknowledgedBy = user.name
        updated.acknowledgedAt = AlertSampleData.acknowledgementTimestamp
        return updated
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
