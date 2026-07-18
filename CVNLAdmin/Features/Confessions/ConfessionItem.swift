import Foundation

/// Confession moderation status. Numeric values match rc-admin-server / rc-admin-web.
enum ConfessionStatus: Int, CaseIterable, Sendable, Codable, Equatable {
    case pending = 0
    case rejected = 1
    case approved = 2

    var filterLabel: String {
        switch self {
        case .pending:
            return "Pending"
        case .rejected:
            return "Rejected"
        case .approved:
            return "Approved"
        }
    }
}

/// Filter options for the confession list (includes "All").
enum ConfessionFilter: Hashable, Sendable {
    case all
    case status(ConfessionStatus)

    var label: String {
        switch self {
        case .all:
            return "All"
        case .status(let status):
            return status.filterLabel
        }
    }

    /// API `status` query value; nil means omit (All).
    var apiStatus: Int? {
        switch self {
        case .all:
            return nil
        case .status(let status):
            return status.rawValue
        }
    }

    static let allCases: [ConfessionFilter] = [
        .all,
        .status(.pending),
        .status(.approved),
        .status(.rejected),
    ]
}

/// Single confession from GET /api/confessions.
struct ConfessionItem: Identifiable, Equatable, Sendable, Decodable {
    let id: String
    var content: String
    let createdAt: Date
    var status: ConfessionStatus
    let row: Int
    var number: Int

    /// Display timestamp for the card header (mock: "Jul 10, 2026 · 16:10").
    var createdAtText: String {
        Self.displayFormatter.string(from: createdAt)
    }

    /// Number shown in the `#` chip; empty when unset (0).
    var numberDisplay: String {
        number > 0 ? String(number) : ""
    }

    var canPostToFacebook: Bool {
        status == .approved && number > 0
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt
        case status
        case row
        case number
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Server may return Mongo id as string; tolerate int/double just in case.
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }

        content = try container.decode(String.self, forKey: .content)
        createdAt = try Self.decodeDate(from: container, forKey: .createdAt)

        let statusRaw = try container.decode(Int.self, forKey: .status)
        status = ConfessionStatus(rawValue: statusRaw) ?? .pending

        row = try container.decodeIfPresent(Int.self, forKey: .row) ?? 0
        number = try container.decodeIfPresent(Int.self, forKey: .number) ?? 0
    }

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Mock format: "Jul 10, 2026 · 16:10"
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
}
