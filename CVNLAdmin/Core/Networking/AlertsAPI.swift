import Foundation

struct AlertsListResponse: Decodable {
    let alerts: [AlertItem]
}

struct AlertResponse: Decodable {
    let alert: AlertItem
}

struct EmptyBody: Encodable {}

@MainActor
final class AlertsAPI {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func listAlerts() async throws -> [AlertItem] {
        let response: AlertsListResponse = try await httpClient.get(path: "/alerts")
        return response.alerts
    }

    func acknowledge(alertID: String) async throws -> AlertItem {
        let response: AlertResponse = try await httpClient.post(
            path: "/alerts/\(alertID)/acknowledge",
            body: EmptyBody()
        )
        return response.alert
    }

    func acknowledgeAll() async throws -> [AlertItem] {
        let response: AlertsListResponse = try await httpClient.post(
            path: "/alerts/acknowledge-all",
            body: EmptyBody()
        )
        return response.alerts
    }
}
