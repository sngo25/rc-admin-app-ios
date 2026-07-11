import Foundation

extension Notification.Name {
    /// Posted when an admin alert push is received or the app should refresh alerts.
    static let adminAlertReceived = Notification.Name("adminAlertReceived")
}

enum AdminAlertPushNotification {
    private static let alertType = "alert"

    /// Returns true when the push payload is an admin alert refresh signal.
    static func isAlertNotification(userInfo: [AnyHashable: Any]) -> Bool {
        guard let type = stringValue(userInfo: userInfo, key: "type") else {
            return false
        }

        return type == alertType
    }

    /// Posts a refresh signal for the Alerts inbox.
    static func postAlertRefreshNeeded() {
        NotificationCenter.default.post(name: .adminAlertReceived, object: nil)
    }

    static func postReceivedIfNeeded(userInfo: [AnyHashable: Any]) {
        // All admin pushes are alerts today; refresh even if FCM nested the data payload.
        if isAlertNotification(userInfo: userInfo) {
            postAlertRefreshNeeded()
            return
        }

        // FCM may omit custom data in userInfo for display notifications; still refresh.
        if hasNotificationContent(userInfo: userInfo) {
            postAlertRefreshNeeded()
        }
    }

    private static func hasNotificationContent(userInfo: [AnyHashable: Any]) -> Bool {
        guard let aps = userInfo["aps"] as? [AnyHashable: Any] else {
            return false
        }

        if aps["alert"] != nil {
            return true
        }

        if let alert = aps["alert"] as? [AnyHashable: Any], alert["body"] != nil {
            return true
        }

        return false
    }

    private static func stringValue(userInfo: [AnyHashable: Any], key: String) -> String? {
        if let value = userInfo[key] as? String {
            return value
        }

        if let value = userInfo[key] as? NSString {
            return value as String
        }

        if let data = userInfo["data"] as? [AnyHashable: Any] {
            if let value = data[key] as? String {
                return value
            }

            if let value = data[key] as? NSString {
                return value as String
            }
        }

        if let gcmData = userInfo["gcm.notification.data"] as? [AnyHashable: Any],
           let value = gcmData[key] as? String
        {
            return value
        }

        return nil
    }
}
