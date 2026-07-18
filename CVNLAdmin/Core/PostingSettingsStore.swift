import Foundation
import Observation

/// Local confession posting settings (mirrors rc-admin-web Redux confession settings).
/// Persisted in UserDefaults until Confession publish syncs with the server.
@Observable
final class PostingSettingsStore {
    static let shared = PostingSettingsStore()

    private enum Keys {
        static let postedCount = "postingSettings.postedCount"
        static let intervalMinutes = "postingSettings.intervalMinutes"
        static let lastPostedAt = "postingSettings.lastPostedAt"
    }

    private let defaults: UserDefaults

    /// Web equivalent: `lastNumber` — confessions posted so far.
    var postedCount: Int {
        didSet { defaults.set(postedCount, forKey: Keys.postedCount) }
    }

    /// Web equivalent: `minutesBetweenPost`.
    var intervalMinutes: Int {
        didSet { defaults.set(intervalMinutes, forKey: Keys.intervalMinutes) }
    }

    /// Web equivalent: `lastPublishTime` (epoch ms). Display-only in the settings UI.
    var lastPostedAt: Date? {
        didSet {
            if let lastPostedAt {
                defaults.set(lastPostedAt.timeIntervalSince1970 * 1000, forKey: Keys.lastPostedAt)
            } else {
                defaults.removeObject(forKey: Keys.lastPostedAt)
            }
        }
    }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Defaults match web reducer: lastNumber 0, minutesBetweenPost 15, lastPublishTime unset.
        if defaults.object(forKey: Keys.postedCount) != nil {
            postedCount = defaults.integer(forKey: Keys.postedCount)
        } else {
            postedCount = 0
        }

        if defaults.object(forKey: Keys.intervalMinutes) != nil {
            intervalMinutes = defaults.integer(forKey: Keys.intervalMinutes)
        } else {
            intervalMinutes = 15
        }

        let millis = defaults.double(forKey: Keys.lastPostedAt)
        if millis > 0 {
            lastPostedAt = Date(timeIntervalSince1970: millis / 1000)
        } else {
            lastPostedAt = nil
        }
    }

    /// Applies edited values from the settings dialog.
    func save(postedCount: Int, intervalMinutes: Int) {
        self.postedCount = max(0, postedCount)
        self.intervalMinutes = max(1, intervalMinutes)
    }

    /// Bumps `postedCount` when a confession number is assigned above the current max (web lastNumber).
    func noteAssignedNumber(_ number: Int) {
        if number > postedCount {
            postedCount = number
        }
    }

    /// Returns a non-zero `postedCount`, fetching it from the 5 newest Facebook posts when local is 0.
    /// Leaves `postedCount` at 0 when the feed has no `#CVNL` tags.
    @MainActor
    func ensurePostedCount(using facebookAPI: FacebookAPI) async throws -> Int {
        if postedCount > 0 {
            return postedCount
        }

        let feed = try await facebookAPI.getPageFeed()
        if let maxNumber = LatestPostedNumberResolver.maxConfessionNumber(from: feed) {
            noteAssignedNumber(maxNumber)
        }

        return postedCount
    }

    /// Records when a fan-page post was published or scheduled (web: setLastPublishTime).
    func recordPublish(at date: Date) {
        lastPostedAt = date
    }

    /// Next allowed publish time based on last post + interval, if still in the future.
    var suggestedScheduleDate: Date? {
        guard let lastPostedAt else {
            return nil
        }

        let next = lastPostedAt.addingTimeInterval(TimeInterval(intervalMinutes * 60))
        return next > Date() ? next : nil
    }
}
