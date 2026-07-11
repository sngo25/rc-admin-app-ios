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
    }

    func restoreSession() async {
        state = .checking

        guard TokenStore.loadRefreshToken() != nil else {
            state = .unauthenticated
            return
        }

        do {
            try await authAPI.refresh()
            let user = try await authAPI.getCurrentUser()
            httpClient.resetSession()
            setState(for: user)
        } catch {
            TokenStore.clearRefreshToken()
            httpClient.setAccessToken(nil)
            state = .unauthenticated
        }
    }

    func login(username: String, password: String) async throws {
        let response = try await authAPI.login(username: username, password: password)
        httpClient.resetSession()
        setState(for: response.user)
    }

    func logout() async {
        await authAPI.logout()
        state = .unauthenticated
    }

    private func setState(for user: AdminUser) {
        if UserRole.isAllowed(user.role) {
            state = .authenticated(user)
        } else {
            state = .forbidden(user)
        }
    }

    private func handleSessionExpired() {
        TokenStore.clearRefreshToken()
        state = .unauthenticated
    }
}
