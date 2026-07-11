//
//  CVNLAdminApp.swift
//  CVNLAdmin
//

import SwiftUI

@main
struct CVNLAdminApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationDelegate.self) private var pushDelegate
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
        }
    }
}
