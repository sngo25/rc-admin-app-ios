import Foundation

/// Builds the Facebook post body for a confession (same format as rc-admin-web `buildPost`).
func buildPost(confession: ConfessionItem) -> String {
    let date = ConfessionBuildPost.dateFormatter.string(from: confession.createdAt)
    return "#CVNL\(confession.number)\n[\(date)] \(confession.content)\n\n---\n"
}

private enum ConfessionBuildPost {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Web formatDate: dd/MM/yyyy
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}
