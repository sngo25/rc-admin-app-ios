import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationManager {
    static let shared = PushNotificationManager()

    private var httpClient: HTTPClient?
    private var assignedToken: String?

    private init() {}

    func configure(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func requestPermissionAndRegister() async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])

            if granted {
                AppLogger.pushInfo("Notification permission granted")
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                AppLogger.pushWarning("Notification permission denied")
            }
        } catch {
            AppLogger.pushError("Notification permission request failed: \(error.localizedDescription)")
        }
    }

    func syncTokenIfNeeded() async {
        guard let httpClient else {
            AppLogger.pushWarning("Skipping FCM sync: HTTPClient not configured")
            return
        }

        do {
            let token = try await Messaging.messaging().token()
            try await syncToken(token, httpClient: httpClient)
        } catch {
            AppLogger.pushError("FCM token sync failed: \(error.localizedDescription)")
        }
    }

    func handleTokenRefresh(_ token: String) async {
        guard let httpClient else {
            return
        }

        do {
            try await syncToken(token, httpClient: httpClient)
        } catch {
            AppLogger.pushError("FCM token refresh sync failed: \(error.localizedDescription)")
        }
    }

    func unregister() async {
        guard let httpClient else {
            return
        }

        guard let token = assignedToken else {
            return
        }

        let api = DeviceTokenAPI(httpClient: httpClient)

        do {
            try await api.unregister(token: token)
            AppLogger.pushInfo("Unregistered FCM token from server")
            assignedToken = nil
        } catch {
            AppLogger.pushError("FCM token unregister failed: \(error.localizedDescription)")
        }
    }

    private func syncToken(_ token: String, httpClient: HTTPClient) async throws {
        let oldToken = assignedToken != token ? assignedToken : nil
        let api = DeviceTokenAPI(httpClient: httpClient)

        try await api.register(token: token, oldToken: oldToken)
        assignedToken = token
        AppLogger.pushInfo("Registered FCM token with server")
    }
}
