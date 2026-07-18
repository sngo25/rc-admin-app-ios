import Foundation

/// Derives latest confession number and last-posted time from Facebook page feed posts.
enum LatestPostedNumberResolver {
    /// How many newest feed items to scan for `#CVNL` tags.
    /// Wider than a handful so non-confession posts between confessions do not hide the latest number.
    static let latestPostLimit = 15

    /// Returns the maximum `#CVNL` number among the newest posts, or nil when none found.
    /// Assumes `items` are already sorted newest-first (see `FacebookAPI.getPageFeed`).
    static func maxConfessionNumber(
        from items: [PageFeedItem],
        limit: Int = latestPostLimit
    ) -> Int? {
        let newest = items.prefix(limit)
        var maxNumber: Int?

        for item in newest {
            for number in item.confessionNumbers {
                if let current = maxNumber {
                    maxNumber = max(current, number)
                } else {
                    maxNumber = number
                }
            }
        }

        return maxNumber
    }

    /// Returns the newest `createdTime` among posts that contain a `#CVNL` tag, or nil when none found.
    /// Uses the same scan window as `maxConfessionNumber` (scheduled + published).
    static func latestPostedAt(
        from items: [PageFeedItem],
        limit: Int = latestPostLimit
    ) -> Date? {
        let newest = items.prefix(limit)
        var latest: Date?

        for item in newest {
            // Only confession posts contribute to "Last posted at".
            guard !item.confessionNumbers.isEmpty else {
                continue
            }

            if let current = latest {
                latest = max(current, item.createdTime)
            } else {
                latest = item.createdTime
            }
        }

        return latest
    }
}
