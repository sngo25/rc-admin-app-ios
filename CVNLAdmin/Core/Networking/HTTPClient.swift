import Foundation

@MainActor
final class HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()

    private var accessToken: String?
    private var refreshTask: Task<AuthTokens, Error>?
    private var sessionInvalidated = false

    var onSessionExpired: (() -> Void)?

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        AppLogger.networkInfo("HTTPClient base URL: \(baseURL.absoluteString)")
    }

    func setAccessToken(_ token: String?) {
        accessToken = token
    }

    func getAccessToken() -> String? {
        accessToken
    }

    func invalidateSession() {
        sessionInvalidated = true
        accessToken = nil
        onSessionExpired?()
    }

    func resetSession() {
        sessionInvalidated = false
    }

    func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        isRetry: Bool = false
    ) async throws -> T {
        try await request(
            path: path,
            method: "GET",
            body: Optional<String>.none,
            queryItems: queryItems,
            isRetry: isRetry
        )
    }

    func post<T: Decodable, Body: Encodable>(
        path: String,
        body: Body,
        isRetry: Bool = false
    ) async throws -> T {
        try await request(
            path: path,
            method: "POST",
            body: body,
            queryItems: [],
            isRetry: isRetry
        )
    }

    func postCommand<Body: Encodable>(
        path: String,
        body: Body,
        isRetry: Bool = false
    ) async throws {
        try await commandRequest(
            path: path,
            method: "POST",
            body: body,
            isRetry: isRetry
        )
    }

    func deleteCommand<Body: Encodable>(
        path: String,
        body: Body,
        isRetry: Bool = false
    ) async throws {
        try await commandRequest(
            path: path,
            method: "DELETE",
            body: body,
            isRetry: isRetry
        )
    }

    private func commandRequest<Body: Encodable>(
        path: String,
        method: String,
        body: Body,
        isRetry: Bool
    ) async throws {
        let url = try makeURL(path: path, queryItems: [])
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            ClientConfig.nativeClientValue,
            forHTTPHeaderField: ClientConfig.nativeClientHeaderName
        )

        if let accessToken {
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        AppLogger.networkInfo("\(method) \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.networkError("Invalid response for \(request.url?.absoluteString ?? path)")
            throw APIError.invalidResponse
        }

        logResponse(method: method, url: url, statusCode: httpResponse.statusCode, data: data)

        if httpResponse.statusCode == 401,
           !isRetry,
           !sessionInvalidated,
           path != "/auth/refresh",
           path != "/auth/login"
        {
            let didRefresh = try await refreshAccessToken()

            if didRefresh {
                try await commandRequest(
                    path: path,
                    method: method,
                    body: body,
                    isRetry: true
                )
                return
            }
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw apiError(fromFailureBody: data, statusCode: httpResponse.statusCode)
        }

        do {
            let envelope = try decoder.decode(APIEnvelope<EmptyData>.self, from: data)
            try envelope.validateSuccess()
        } catch {
            logDecodeFailure(method: method, url: url, data: data, error: error)
            throw error
        }
    }

    func setRefreshHandler(_ handler: @escaping () async throws -> AuthTokens) {
        refreshHandler = handler
    }

    private var refreshHandler: (() async throws -> AuthTokens)?

    private func request<T: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body?,
        queryItems: [URLQueryItem],
        isRetry: Bool
    ) async throws -> T {
        let url = try makeURL(path: path, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            ClientConfig.nativeClientValue,
            forHTTPHeaderField: ClientConfig.nativeClientHeaderName
        )

        if let accessToken {
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        } else if method != "GET" {
            request.httpBody = Data("{}".utf8)
        }

        AppLogger.networkInfo("\(method) \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.networkError("Invalid response for \(url.absoluteString)")
            throw APIError.invalidResponse
        }

        logResponse(method: method, url: url, statusCode: httpResponse.statusCode, data: data)

        if httpResponse.statusCode == 401,
           !isRetry,
           !sessionInvalidated,
           path != "/auth/refresh",
           path != "/auth/login"
        {
            let didRefresh = try await refreshAccessToken()

            if didRefresh {
                return try await self.request(
                    path: path,
                    method: method,
                    body: body,
                    queryItems: queryItems,
                    isRetry: true
                )
            }
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw apiError(fromFailureBody: data, statusCode: httpResponse.statusCode)
        }

        do {
            let envelope = try decoder.decode(APIEnvelope<T>.self, from: data)
            return try envelope.unwrap()
        } catch {
            logDecodeFailure(method: method, url: url, data: data, error: error)
            throw error
        }
    }

    /// Prefer server `error_message` on real HTTP failures; fall back to status code.
    private func apiError(fromFailureBody data: Data, statusCode: Int) -> APIError {
        if let envelope = try? decoder.decode(APIEnvelope<EmptyData>.self, from: data) {
            let trimmed = envelope.errorMessage?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let trimmed, !trimmed.isEmpty {
                return .server(code: envelope.errorCode, message: trimmed)
            }
        }

        if let payload = try? decoder.decode(APIErrorBody.self, from: data) {
            let trimmed = payload.errorMessage?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let trimmed, !trimmed.isEmpty {
                return .server(code: payload.errorCode, message: trimmed)
            }
        }

        return .httpStatus(statusCode)
    }

    private func logResponse(method: String, url: URL, statusCode: Int, data: Data) {
        if (200 ... 299).contains(statusCode) {
            AppLogger.networkInfo("\(method) \(url.absoluteString) -> \(statusCode)")
            return
        }

        AppLogger.networkError(
            "\(method) \(url.absoluteString) -> \(statusCode): \(Self.responsePreview(data))"
        )
    }

    private func logDecodeFailure(method: String, url: URL, data: Data, error: Error) {
        AppLogger.networkError(
            "Decode failed for \(method) \(url.absoluteString): \(error.localizedDescription); body: \(Self.responsePreview(data))"
        )
    }

    private static func responsePreview(_ data: Data, maxLength: Int = 500) -> String {
        let text = String(data: data, encoding: .utf8) ?? "<non-utf8 \(data.count) bytes>"
        if text.count <= maxLength {
            return text
        }

        return String(text.prefix(maxLength)) + "…"
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidResponse
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        return url
    }

    @discardableResult
    private func refreshAccessToken() async throws -> Bool {
        if sessionInvalidated {
            return false
        }

        if let refreshTask {
            let tokens = try await refreshTask.value
            accessToken = tokens.accessToken
            return true
        }

        guard let refreshHandler else {
            invalidateSession()
            return false
        }

        let task = Task { try await refreshHandler() }
        refreshTask = task

        defer { refreshTask = nil }

        do {
            let tokens = try await task.value
            accessToken = tokens.accessToken
            resetSession()
            return true
        } catch {
            invalidateSession()
            return false
        }
    }
}

private struct EmptyData: Decodable {}

/// Partial error body when the response is not a full success/error envelope.
private struct APIErrorBody: Decodable {
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}
