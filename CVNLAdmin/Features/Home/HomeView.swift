import SwiftUI

struct HomeView: View {
    let user: AdminUser
    let onLogout: () async -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome, \(user.name)")
                    .font(.title2)

                Text(roleLabel)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("CVNL Admin")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        Task {
                            await onLogout()
                        }
                    }
                }
            }
        }
    }

    private var roleLabel: String {
        if UserRole.isAdmin(user.role) {
            return "Admin"
        }

        if UserRole.isModerator(user.role) {
            return "Moderator"
        }

        return "User"
    }
}
