import SwiftUI

/// Shared color tokens for the admin app UI.
/// Values match the CVNL Admin design mocks (admin-app-standalone.html, admin-app-standalone-2.html).
enum AdminTheme {
    static let primary = Color(hex: 0x6E56CF)
    static let primaryPressed = Color(hex: 0x5B45B8)
    static let focusRing = Color(hex: 0xEEE9FB)
    static let textPrimary = Color(hex: 0x1B1B1F)
    static let textSecondary = Color(hex: 0x8A8A93)
    static let textTertiary = Color(hex: 0xA0A0A8)
    static let border = Color(hex: 0xE1E1E6)
    static let background = Color(hex: 0xFFFFFF)

    // Alerts screen tokens (admin-app-standalone-2.html).
    static let screenBackground = Color(hex: 0xF6F6F8)
    static let divider = Color(hex: 0xECECEF)
    static let bodySecondary = Color(hex: 0x5C5C64)
    static let iconMuted = Color(hex: 0x43434B)
    static let iconButtonHover = Color(hex: 0xF2F2F5)
    // Posting settings / Post to fan page dialogs (Confession list mockup).
    static let settingsCancelBackground = Color(hex: 0xF3F3F5)
    static let settingsCancelBackgroundPressed = Color(hex: 0xE9E9EC)
    static let settingsBackdrop = Color(red: 20 / 255, green: 20 / 255, blue: 28 / 255)
    static let scheduleCheckboxBorder = Color(hex: 0xCFCFD6)
    static let scheduleCheckboxLabel = Color(hex: 0x26262B)
    static let scheduleDateDisabled = Color(hex: 0xB4B4BB)
    static let ackAllBackground = Color(hex: 0xF1EEFB)
    static let ackAllBackgroundPressed = Color(hex: 0xE8E2F8)
    static let cardBorder = Color(hex: 0xECECEF)
    static let cardDivider = Color(hex: 0xF1F1F3)
    static let emptyTitle = Color(hex: 0x6C6C75)

    // Severity chips.
    static let criticalBackground = Color(hex: 0xFCEDED)
    static let criticalForeground = Color(hex: 0xCB3A3A)
    static let warningBackground = Color(hex: 0xFBF1DE)
    static let warningForeground = Color(hex: 0x9A6700)
    static let infoBackground = Color(hex: 0xEFF3FA)
    static let infoForeground = Color(hex: 0x3E6DB5)
    static let successBackground = Color(hex: 0xE7F5EE)
    static let successForeground = Color(hex: 0x12875A)

    // Confession list screen tokens (Confession list mockup).
    static let filterBackground = Color(hex: 0xF0F0F3)
    static let rejectBorder = Color(hex: 0xF0D2D2)
    static let approveGreenPressed = Color(hex: 0x0F7350)
    static let facebookBlue = Color(hex: 0x1877F2)
    static let facebookBluePressed = Color(hex: 0x1465D8)
    static let confessionBody = Color(hex: 0x26262B)
    static let pagerDisabledText = Color(hex: 0xBDBDC4)
}

private extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
