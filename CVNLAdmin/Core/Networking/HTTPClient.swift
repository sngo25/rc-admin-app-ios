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
        let url = try makeURL(path: path, queryItems: [])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            ClientConfig.nativeClientValue,
            forHTTPHeaderField: ClientConfig.nativeClientHeaderName
        )

        if let accessToken {
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(httpResponse.statusCode)
        }

        let envelope = try decoder.decode(APIEnvelope<EmptyData>.self, from: data)
        try envelope.validateSuccess()
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

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

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
            throw APIError.httpStatus(httpResponse.statusCode)
        }

        let envelope = try decoder.decode(APIEnvelope<T>.self, from: data)
        return try envelope.unwrap()
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
