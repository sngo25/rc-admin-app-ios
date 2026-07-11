import Foundation

struct RefreshTokenBody: Encodable {
    let refreshToken: String
}

struct LoginBody: Encodable {
    let username: String
    let password: String
}

@MainActor
final class AuthAPI {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient

        httpClient.setRefreshHandler { [weak self] in
            guard let self else {
                throw APIError.unauthorized
            }

            return try await self.refresh()
        }
    }

    func login(username: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await httpClient.post(
            path: "/auth/login",
            body: LoginBody(username: username, password: password)
        )

        httpClient.setAccessToken(response.accessToken)

        if let refreshToken = response.refreshToken {
            try TokenStore.saveRefreshToken(refreshToken)
        }

        return response
    }

    @discardableResult
    func refresh() async throws -> AuthTokens {
        guard let refreshToken = TokenStore.loadRefreshToken() else {
            throw APIError.unauthorized
        }

        let tokens: AuthTokens = try await httpClient.post(
            path: "/auth/refresh",
            body: RefreshTokenBody(refreshToken: refreshToken)
        )

        httpClient.setAccessToken(tokens.accessToken)

        if let newRefreshToken = tokens.refreshToken {
            try TokenStore.saveRefreshToken(newRefreshToken)
        }

        return tokens
    }

    func getCurrentUser() async throws -> AdminUser {
        try await httpClient.get(path: "/auth/user")
    }

    func logout() async {
        if let refreshToken = TokenStore.loadRefreshToken() {
            try? await httpClient.postCommand(
                path: "/auth/logout",
                body: RefreshTokenBody(refreshToken: refreshToken)
            )
        }

        TokenStore.clearRefreshToken()
        httpClient.setAccessToken(nil)
    }
}
