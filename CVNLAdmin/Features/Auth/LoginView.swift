import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 24) {
            Text("May we ask you to login?")
                .font(.headline)

            LoginFormView { username, password in
                try await authManager.login(username: username, password: password)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
