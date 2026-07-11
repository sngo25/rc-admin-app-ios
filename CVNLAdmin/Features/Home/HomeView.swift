import SwiftUI

/// Post-login shell. Currently hosts the Alerts mock screen.
struct HomeView: View {
    let user: AdminUser
    let onLogout: () async -> Void

    var body: some View {
        AlertsView(user: user, onLogout: onLogout)
    }
}
