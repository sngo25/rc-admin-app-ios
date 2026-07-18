import Foundation

/// Publish state for a Facebook page post row.
enum PageFeedStatus: Sendable {
    case posted
    case scheduled

    var label: String {
        switch self {
        case .posted:
            return "Posted"
        case .scheduled:
            return "Scheduled"
        }
    }
}

/// Single row from GET /api/facebook/getPageFeed.
struct PageFeedItem: Identifiable, Sendable, Decodable {
    let createdTime: Date
    let message: String?
    let isPublished: Bool
    let permalinkUrl: String?

    /// Stable list identity — permalink when present, otherwise created time.
    var id: String {
        permalinkUrl ?? createdTime.timeIntervalSince1970.description
    }

    /// All `#CVNL{number}` integers found in the post body (may be empty).
    var confessionNumbers: [Int] {
        guard let message else {
            return []
        }

        let nsRange = NSRange(message.startIndex..., in: message)
        let matches = Self.confessionTagRegex.matches(in: message, range: nsRange)

        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: message) else {
                return nil
            }
            return Int(message[range])
        }
    }

    /// Parsed `#CVNL{number}` tag from the post body, or nil when absent.
    var confessionTag: String? {
        guard let number = confessionNumbers.first else {
            return nil
        }
        return "#CVNL\(number)"
    }

    /// Full Facebook post message for the card body (shown as-is from the API).
    var bodyText: String {
        message ?? ""
    }

    /// Display timestamp for the card header (matches mock postedAt format).
    var postedAtText: String {
        Self.postedAtFormatter.string(from: createdTime)
    }

    var hasPermalink: Bool {
        permalinkUrl != nil
    }

    var status: PageFeedStatus {
        isPublished ? .posted : .scheduled
    }

    enum CodingKeys: String, CodingKey {
        case createdTime = "created_time"
        case message
        case isPublished = "is_published"
        case permalinkUrl = "permalink_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdTime = try Self.decodeDate(from: container, forKey: .createdTime)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        isPublished = try container.decode(Bool.self, forKey: .isPublished)
        permalinkUrl = try container.decodeIfPresent(String.self, forKey: .permalinkUrl)
    }

    private static let postedAtFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }()

    private static let confessionTagRegex: NSRegularExpression = {
        // Matches #CVNL followed by digits — same pattern as rc-admin-web PagePostsView.
        try! NSRegularExpression(pattern: "#CVNL(\\d+)")
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]
        return formatter
    }()

    private static let isoFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func decodeDate(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> Date {
        let value = try container.decode(String.self, forKey: key)

        if let date = isoFormatter.date(from: value) {
            return date
        }

        if let date = isoFormatterNoFraction.date(from: value) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Invalid ISO 8601 date: \(value)"
        )
    }
}
