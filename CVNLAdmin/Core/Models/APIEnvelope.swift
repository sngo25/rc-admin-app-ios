import Foundation

struct APIEnvelope<T: Decodable>: Decodable {
    let status: String
    let data: T?
    let errorCode: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }

    func unwrap() throws -> T {
        try validateSuccess()

        guard let data else {
            throw APIError.missingData
        }

        return data
    }

    func validateSuccess() throws {
        if status == "error" {
            throw APIError.server(
                code: errorCode,
                message: errorMessage ?? "Unknown error"
            )
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case server(code: Int?, message: String)
    case missingData
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpStatus(let code):
            return "Request failed with status \(code)"
        case .server(_, let message):
            return message
        case .missingData:
            return "Missing response data"
        case .unauthorized:
            return "Session expired"
        }
    }
}
