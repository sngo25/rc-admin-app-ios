import Foundation

struct ConfessionsListResponse: Decodable {
    let items: [ConfessionItem]
    let total: Int
}

/// Body for POST /confessions/:id (status and optional number).
struct ConfessionUpdateBody: Encodable {
    let status: Int
    let number: Int?

    private enum CodingKeys: String, CodingKey {
        case status
        case number
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        // Omit null so the server leaves number unchanged when not provided.
        try container.encodeIfPresent(number, forKey: .number)
    }
}

@MainActor
final class ConfessionAPI {
    static let pageSize = 20

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    /// Fetches one page of confessions. Pass `status: nil` for All.
    func list(limit: Int, offset: Int, status: Int?) async throws -> ConfessionsListResponse {
        var queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
        ]

        if let status {
            queryItems.append(URLQueryItem(name: "status", value: String(status)))
        }

        return try await httpClient.get(path: "/confessions", queryItems: queryItems)
    }

    /// Updates confession status and/or number.
    func update(id: String, status: ConfessionStatus, number: Int?) async throws {
        try await httpClient.postCommand(
            path: "/confessions/\(id)",
            body: ConfessionUpdateBody(status: status.rawValue, number: number)
        )
    }
}
