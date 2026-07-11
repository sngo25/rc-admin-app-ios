import Foundation

/// Severity level for an admin alert card.
enum AlertSeverity: String, CaseIterable, Sendable {
    case critical
    case warning
    case info

    var label: String {
        switch self {
        case .critical:
            return "Critical"
        case .warning:
            return "Warning"
        case .info:
            return "Info"
        }
    }
}

/// Local alert model used by the mock Alerts screen.
/// Real API wiring will replace the sample fixtures later.
struct AlertItem: Identifiable, Equatable, Sendable {
    let id: Int
    let severity: AlertSeverity
    let title: String
    let message: String
    let time: String
    let sortOrder: Int
    var isAcknowledged: Bool
    var acknowledgedBy: String?
    var acknowledgedAt: String?

    /// Unacked alerts first, then newest by sort order.
    func sortKey() -> (Int, Int) {
        (isAcknowledged ? 1 : 0, -sortOrder)
    }
}

enum AlertSampleData {
    /// Fixed acknowledgement timestamp shown in the mock.
    static let acknowledgementTimestamp = "Jul 11, 2026 · 15:50"

    /// Sample alerts copied from admin-app-standalone-2.html.
    static func alerts() -> [AlertItem] {
        [
            AlertItem(
                id: 101,
                severity: .critical,
                title: "Payment gateway webhook failing",
                message: "Stripe webhook delivery has failed 14 times in the last hour. Payments may not be reconciling.",
                time: "Jul 11, 2026 · 14:32",
                sortOrder: 6,
                isAcknowledged: false
            ),
            AlertItem(
                id: 102,
                severity: .warning,
                title: "Spam detection accuracy dropped",
                message: "The auto-moderation model’s accuracy fell to 82%, below the 90% threshold. Consider reviewing recent flags manually.",
                time: "Jul 11, 2026 · 09:05",
                sortOrder: 5,
                isAcknowledged: false
            ),
            AlertItem(
                id: 103,
                severity: .warning,
                title: "Approved queue backlog exceeds 500 items",
                message: "There are 512 approved confessions waiting to be posted. Posting interval may need adjustment.",
                time: "Jul 10, 2026 · 22:40",
                sortOrder: 4,
                isAcknowledged: false
            ),
            AlertItem(
                id: 104,
                severity: .info,
                title: "Weekly digest sent",
                message: "The weekly confession digest was emailed to 12,400 subscribers.",
                time: "Jul 10, 2026 · 08:00",
                sortOrder: 3,
                isAcknowledged: true,
                acknowledgedBy: "Linh",
                acknowledgedAt: "Jul 10, 2026 · 08:15"
            ),
            AlertItem(
                id: 105,
                severity: .critical,
                title: "Database replica lag exceeded threshold",
                message: "Read replica lag reached 48s, above the 30s alert threshold. Resolved automatically after failover.",
                time: "Jul 9, 2026 · 03:12",
                sortOrder: 2,
                isAcknowledged: true,
                acknowledgedBy: "Sang",
                acknowledgedAt: "Jul 9, 2026 · 03:40"
            ),
            AlertItem(
                id: 106,
                severity: .info,
                title: "New admin account created",
                message: "An admin account for minh.tran was created and granted moderator access.",
                time: "Jul 8, 2026 · 11:00",
                sortOrder: 1,
                isAcknowledged: true,
                acknowledgedBy: "Sang",
                acknowledgedAt: "Jul 8, 2026 · 11:02"
            ),
        ]
    }
}
