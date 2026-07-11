import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    LoginBrandHeader()
                        .padding(.top, 8)

                    Spacer(minLength: 48)

                    // Welcome copy and form, vertically centered in remaining space.
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome back")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(AdminTheme.textPrimary)
                                .tracking(-0.6)

                            Text("Sign in to review the confession queue.")
                                .font(.system(size: 14))
                                .foregroundStyle(AdminTheme.textSecondary)
                        }

                        LoginFormView { username, password in
                            try await authManager.login(username: username, password: password)
                        }
                    }

                    Spacer(minLength: 48)
                }
                .padding(.horizontal, 28)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AdminTheme.background)
    }
}
