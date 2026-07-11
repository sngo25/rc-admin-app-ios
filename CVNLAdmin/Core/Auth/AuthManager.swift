import Foundation
import Observation

enum AuthState: Equatable {
    case checking
    case unauthenticated
    case authenticated(AdminUser)
    case forbidden(AdminUser)
}

@MainActor
@Observable
final class AuthManager {
    private(set) var state: AuthState = .checking

    private let authAPI: AuthAPI
    private let httpClient: HTTPClient

    init(authAPI: AuthAPI? = nil) {
        let httpClient = HTTPClient(baseURL: AppConfig.serverURL)
        self.httpClient = httpClient
        self.authAPI = authAPI ?? AuthAPI(httpClient: httpClient)

        httpClient.onSessionExpired = { [weak self] in
            self?.handleSessionExpired()
        }

        PushNotificationManager.shared.configure(httpClient: httpClient)
    }

    func restoreSession() async {
        state = .checking

        guard TokenStore.loadRefreshToken() != nil else {
            AppLogger.authInfo("No refresh token stored; showing login")
            state = .unauthenticated
            return
        }

        AppLogger.authInfo("Restoring session from stored refresh token")

        do {
            try await authAPI.refresh()
            let user = try await authAPI.getCurrentUser()
            httpClient.resetSession()
            setState(for: user)
        } catch {
            AppLogger.authError("Session restore failed: \(error.localizedDescription)")
            TokenStore.clearRefreshToken()
            httpClient.setAccessToken(nil)
            state = .unauthenticated
        }
    }

    func login(username: String, password: String) async throws {
        AppLogger.authInfoMasked("Login attempt for username", value: username)

        do {
            let response = try await authAPI.login(username: username, password: password)
            httpClient.resetSession()
            AppLogger.authInfo(
                "Login API succeeded for user id=\(response.id) role=\(response.role)"
            )
            setState(for: response.user)
        } catch {
            AppLogger.authError("Login failed: \(error.localizedDescription)")
            throw error
        }
    }

    func logout() async {
        await PushNotificationManager.shared.unregister()
        await authAPI.logout()
        state = .unauthenticated
    }

    private func setState(for user: AdminUser) {
        if UserRole.isAllowed(user.role) {
            AppLogger.authInfo("Authenticated user \(user.id) (\(user.name))")
            state = .authenticated(user)
            Task {
                await PushNotificationManager.shared.requestPermissionAndRegister()
                await PushNotificationManager.shared.syncTokenIfNeeded()
            }
        } else {
            AppLogger.authWarning(
                "Access denied for user \(user.id) role=\(user.role) (requires admin or moderator)"
            )
            state = .forbidden(user)
        }
    }

    private func handleSessionExpired() {
        TokenStore.clearRefreshToken()
        state = .unauthenticated
    }
}
