import SwiftUI

/// Shared color tokens for the admin app UI.
/// Values match the CVNL Admin design mock (admin-app-standalone.html).
enum AdminTheme {
    static let primary = Color(hex: 0x6E56CF)
    static let primaryPressed = Color(hex: 0x5B45B8)
    static let focusRing = Color(hex: 0xEEE9FB)
    static let textPrimary = Color(hex: 0x1B1B1F)
    static let textSecondary = Color(hex: 0x8A8A93)
    static let textTertiary = Color(hex: 0xA0A0A8)
    static let border = Color(hex: 0xE1E1E6)
    static let background = Color(hex: 0xFFFFFF)
}

private extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
