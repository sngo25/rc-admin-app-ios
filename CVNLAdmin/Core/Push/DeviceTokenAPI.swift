import Foundation

struct DeviceTokenBody: Encodable {
    let token: String
    let oldToken: String?
}

struct UnregisterDeviceTokenBody: Encodable {
    let token: String
}

@MainActor
final class DeviceTokenAPI {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func register(token: String, oldToken: String? = nil) async throws {
        try await httpClient.postCommand(
            path: "/auth/device-token",
            body: DeviceTokenBody(token: token, oldToken: oldToken)
        )
    }

    func unregister(token: String) async throws {
        try await httpClient.deleteCommand(
            path: "/auth/device-token",
            body: UnregisterDeviceTokenBody(token: token)
        )
    }
}
