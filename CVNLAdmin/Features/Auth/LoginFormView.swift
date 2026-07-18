import SwiftUI

struct LoginFormView: View {
    @Environment(AuthManager.self) private var authManager

    let onSubmit: (String, String) async throws -> Void

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field {
        case username
        case password
    }

    private var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            labeledField("Username", field: .username) {
                TextField("", text: $username)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .username)
            }

            labeledField("Password", field: .password) {
                SecureField("", text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
            }

            Button {
                Task {
                    await submit()
                }
            } label: {
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign in")
                            .font(.system(size: 15, weight: .semibold))
                            .tracking(-0.2)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(.white)
                .background(canSubmit ? AdminTheme.primary : AdminTheme.primary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            // Show session-expiry notice once after AuthManager kicks the user to login.
            if let notice = authManager.consumeSessionExpiredMessage() {
                errorMessage = notice
            }
        }
    }

    @ViewBuilder
    private func labeledField<F: View>(
        _ label: String,
        field: Field,
        @ViewBuilder content: () -> F
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AdminTheme.textSecondary)

            content()
                .font(.system(size: 15))
                .foregroundStyle(AdminTheme.textPrimary)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(AdminTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(
                            focusedField == field ? AdminTheme.primary : AdminTheme.border,
                            lineWidth: 1
                        )
                )
                // 3pt focus ring matching the design mock.
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AdminTheme.focusRing, lineWidth: 3)
                        .opacity(focusedField == field ? 1 : 0)
                )
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil

        do {
            try await onSubmit(username, password)
        } catch {
            let message = error.userFacingMessage
            AppLogger.authError("Login form error: \(message)")
            errorMessage = message.isEmpty ? "Login failed" : message
        }

        isLoading = false
    }
}
