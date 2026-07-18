import Foundation

extension Error {
    /// Short message safe to show in UI (toasts, inline form errors, load states).
    /// Prefer server messages; avoid raw decode dumps.
    var userFacingMessage: String {
        if let apiError = self as? APIError {
            return apiError.errorDescription ?? "Something went wrong"
        }

        // Decoding failures are noisy; keep the user-facing copy short.
        if self is DecodingError {
            return "Couldn't read server response"
        }

        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection"
            case .timedOut:
                return "Request timed out"
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return "Could not reach the server"
            default:
                break
            }
        }

        if let localized = self as? LocalizedError,
           let description = localized.errorDescription?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !description.isEmpty
        {
            return description
        }

        let fallback = localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return fallback.isEmpty ? "Something went wrong" : fallback
    }
}
