import Foundation

enum UserRole {
    static let register = 0
    static let admin = 1
    static let moderator = 2

    static func isAdmin(_ role: Int) -> Bool {
        role == admin
    }

    static func isModerator(_ role: Int) -> Bool {
        role == moderator || role == admin
    }

    static func isAllowed(_ role: Int) -> Bool {
        isAdmin(role) || isModerator(role)
    }
}
