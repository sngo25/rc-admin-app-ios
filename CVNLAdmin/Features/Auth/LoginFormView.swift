import SwiftUI

struct LoginFormView: View {
    let onSubmit: (String, String) async throws -> Void

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

            Section {
                Button("Login") {
                    Task {
                        await submit()
                    }
                }
                .disabled(!canSubmit)

                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil

        do {
            try await onSubmit(username, password)
        } catch {
            errorMessage = "Failed"
        }

        isLoading = false
    }
}
