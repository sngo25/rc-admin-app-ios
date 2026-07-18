import Foundation

/// Post-login screens reachable from the hamburger menu.
enum AdminDestination: String, CaseIterable, Identifiable, Sendable {
    case alerts
    case postedToFacebook

    var id: String { rawValue }

    var title: String {
        switch self {
        case .alerts:
            return "Alerts & notifications"
        case .postedToFacebook:
            return "Posted to Facebook"
        }
    }
}
