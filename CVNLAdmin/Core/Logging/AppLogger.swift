import Foundation
import os

/// Centralized logging for debugging auth and network issues in Xcode console.
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "app.cvnl.CVNLAdmin"

    private static let authLogger = Logger(subsystem: subsystem, category: "Auth")
    private static let networkLogger = Logger(subsystem: subsystem, category: "Network")
    private static let pushLogger = Logger(subsystem: subsystem, category: "Push")

    static func authInfo(_ message: String) {
        authLogger.info("\(message, privacy: .public)")
    }

    static func authWarning(_ message: String) {
        authLogger.warning("\(message, privacy: .public)")
    }

    static func authError(_ message: String) {
        authLogger.error("\(message, privacy: .public)")
    }

    static func authInfoMasked(_ label: String, value: String) {
        authLogger.info("\(label, privacy: .public): \(value, privacy: .private(mask: .hash))")
    }

    static func networkInfo(_ message: String) {
        networkLogger.info("\(message, privacy: .public)")
    }

    static func networkError(_ message: String) {
        networkLogger.error("\(message, privacy: .public)")
    }

    static func pushInfo(_ message: String) {
        pushLogger.info("\(message, privacy: .public)")
    }

    static func pushWarning(_ message: String) {
        pushLogger.warning("\(message, privacy: .public)")
    }

    static func pushError(_ message: String) {
        pushLogger.error("\(message, privacy: .public)")
    }
}
