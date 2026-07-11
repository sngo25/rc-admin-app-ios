import Foundation

/// Severity level for an admin alert card.
/// Numeric values match rc-admin-server `AlertSeverity` constants.
enum AlertSeverity: Int, CaseIterable, Sendable, Decodable {
    case info = 0
    case warning = 1
    case critical = 2

    var label: String {
        switch self {
        case .critical:
            return "Critical"
        case .warning:
            return "Warning"
        case .info:
            return "Info"
        }
    }
}

/// Alert row returned by GET /api/alerts.
struct AlertItem: Identifiable, Equatable, Sendable, Decodable {
    let id: String
    let severity: AlertSeverity
    let title: String
    let message: String
    let createdAt: Date
    var isAcknowledged: Bool
    var acknowledgedBy: String?
    var acknowledgedAt: Date?

    /// Display timestamp for the card header.
    var time: String {
        Self.displayFormatter.string(from: createdAt)
    }

    /// Display timestamp for the acknowledged footer.
    var acknowledgedAtText: String? {
        acknowledgedAt.map { Self.displayFormatter.string(from: $0) }
    }

    /// Unacked alerts first, then newest by creation time.
    func sortKey() -> (Int, Date) {
        (isAcknowledged ? 1 : 0, createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case severity
        case title
        case message
        case createdAt
        case isAcknowledged
        case acknowledgedBy
        case acknowledgedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        severity = try container.decode(AlertSeverity.self, forKey: .severity)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        createdAt = try Self.decodeDate(
            from: container,
            forKey: .createdAt
        )
        isAcknowledged = try container.decode(Bool.self, forKey: .isAcknowledged)
        acknowledgedBy = try container.decodeIfPresent(String.self, forKey: .acknowledgedBy)
        acknowledgedAt = try Self.decodeOptionalDate(
            from: container,
            forKey: .acknowledgedAt
        )
    }

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy · HH:mm"
        return formatter
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

    private static func decodeOptionalDate(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> Date? {
        guard try container.decodeIfPresent(String.self, forKey: key) != nil else {
            return nil
        }

        return try decodeDate(from: container, forKey: key)
    }
}
