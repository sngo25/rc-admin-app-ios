import Foundation

struct AdminUser: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let role: Int
}
