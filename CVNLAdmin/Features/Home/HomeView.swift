import SwiftUI

/// Post-login shell that switches between admin screens via the hamburger menu.
struct HomeView: View {
    let user: AdminUser
    let onLogout: () async -> Void

    @State private var destination: AdminDestination = .confessions
    @State private var isMenuPresented = false

    var body: some View {
        Group {
            switch destination {
            case .alerts:
                AlertsView(user: user, onMenuTap: { isMenuPresented = true })

            case .confessions:
                ConfessionsView(user: user, onMenuTap: { isMenuPresented = true })

            case .postedToFacebook:
                PostedToFacebookView(user: user, onMenuTap: { isMenuPresented = true })
            }
        }
        .sheet(isPresented: $isMenuPresented) {
            AdminMenuSheet(
                selectedDestination: destination,
                onSelect: { destination = $0 },
                onLogout: onLogout
            )
        }
    }
}
