import Foundation

struct AuthTokens: Codable, Sendable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String?
}

struct LoginResponse: Codable, Sendable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String?
    let id: String
    let name: String
    let role: Int

    var user: AdminUser {
        AdminUser(id: id, name: name, role: role)
    }
}
