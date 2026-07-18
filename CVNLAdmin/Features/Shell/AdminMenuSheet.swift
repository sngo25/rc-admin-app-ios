import SwiftUI

/// Hamburger menu for switching between admin screens.
struct AdminMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    let selectedDestination: AdminDestination
    let onSelect: (AdminDestination) -> Void
    let onLogout: () async -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AdminDestination.allCases) { destination in
                        Button {
                            onSelect(destination)
                            dismiss()
                        } label: {
                            HStack {
                                Text(destination.title)
                                    .foregroundStyle(AdminTheme.textPrimary)

                                Spacer()

                                if destination == selectedDestination {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AdminTheme.primary)
                                }
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        dismiss()
                        Task {
                            await onLogout()
                        }
                    } label: {
                        Text("Logout")
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
