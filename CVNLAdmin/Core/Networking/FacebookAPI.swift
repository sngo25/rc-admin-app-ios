import Foundation

struct PageFeedResponse: Decodable {
    let items: [PageFeedItem]
}

/// Body for POST /facebook/postToPage (same contract as rc-admin-web).
struct PostToPageBody: Encodable {
    let message: String
    /// Unix seconds when scheduling; omit for immediate publish.
    let publishTime: Int?

    private enum CodingKeys: String, CodingKey {
        case message
        case publishTime
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        // Omit null so the server treats the post as immediate (web sends undefined).
        try container.encodeIfPresent(publishTime, forKey: .publishTime)
    }
}

@MainActor
final class FacebookAPI {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    /// Fetches published and scheduled Facebook page posts.
    func getPageFeed() async throws -> [PageFeedItem] {
        let response: PageFeedResponse = try await httpClient.get(path: "/facebook/getPageFeed")
        return response.items.sorted { $0.createdTime > $1.createdTime }
    }

    /// Publishes (or schedules) a message on the Facebook fan page.
    func postToPage(message: String, publishTime: Int?) async throws {
        try await httpClient.postCommand(
            path: "/facebook/postToPage",
            body: PostToPageBody(message: message, publishTime: publishTime)
        )
    }
}
