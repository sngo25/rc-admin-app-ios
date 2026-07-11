import Foundation
import UserNotifications

/// Syncs the home-screen app icon badge with unacknowledged alert count.
@MainActor
enum AppBadgeManager {
    static func sync(count: Int) async {
        let badge = max(0, count)

        do {
            try await UNUserNotificationCenter.current().setBadgeCount(badge)
        } catch {
            AppLogger.pushError(
                "Failed to set app icon badge to \(badge): \(error.localizedDescription)"
            )
        }
    }

    static func clear() async {
        await sync(count: 0)
    }
}
