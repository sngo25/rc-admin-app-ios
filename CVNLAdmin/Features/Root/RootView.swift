import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Group {
            switch authManager.state {
            case .checking:
                VStack(spacing: 16) {
                    Text("Just a moment, we are checking your identity...")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .unauthenticated:
                LoginView()

            case .authenticated(let user):
                HomeView(user: user) {
                    await authManager.logout()
                }

            case .forbidden(let user):
                ForbiddenView(user: user) {
                    await authManager.logout()
                }
            }
        }
        .task {
            if case .checking = authManager.state {
                await authManager.restoreSession()
            }
        }
    }
}
