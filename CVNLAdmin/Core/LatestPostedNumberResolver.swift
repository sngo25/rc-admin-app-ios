import Foundation

/// Derives the latest confession number from Facebook page feed posts.
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
}
