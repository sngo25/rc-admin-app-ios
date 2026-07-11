import SwiftUI

/// Brand mark and title shown at the top of the login screen.
struct LoginBrandHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            // Purple rounded square with "c" mark.
            Text("c")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(AdminTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text("CVNL Admin")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AdminTheme.textPrimary)

                Text("confession console")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(AdminTheme.textTertiary)
            }
        }
    }
}
