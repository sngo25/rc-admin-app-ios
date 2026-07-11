//
//  CVNLAdminApp.swift
//  CVNLAdmin
//

import SwiftUI

@main
struct CVNLAdminApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
        }
    }
}
