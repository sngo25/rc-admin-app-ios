import SwiftUI

struct ForbiddenView: View {
    let user: AdminUser
    let onLogout: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Access denied")
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(user.name), your account does not have permission to use this app.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Logout") {
                Task {
                    await onLogout()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
