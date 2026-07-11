import Foundation

enum UserRole {
    static let admin = 1
    static let moderator = 2

    static func isRole(_ role: Int, in userRole: Int) -> Bool {
        userRole > 0 && (userRole & role) == role
    }

    static func isAdmin(_ role: Int) -> Bool {
        isRole(admin, in: role)
    }

    static func isModerator(_ role: Int) -> Bool {
        isRole(moderator, in: role)
    }

    static func isAllowed(_ role: Int) -> Bool {
        isAdmin(role) || isModerator(role)
    }
}
