# CVNL Admin iOS Overview

Native iOS admin app for **Random Chat** (CVNL / Seeyu). This project is the iOS counterpart to **rc-admin-web** and talks to **rc-admin-server**.

## Status

Early-stage SwiftUI app with auth infrastructure and login screen. Feature parity with rc-admin-web is the long-term goal.

## Technology Stack

- **Language**: Swift
- **UI framework**: SwiftUI
- **IDE / build**: Xcode (`CVNLAdmin.xcodeproj`)
- **Backend**: rc-admin-server REST API (same as rc-admin-web)

## Intended features

Mirror rc-admin-web admin capabilities:

| Area | Description |
|------|-------------|
| Confessions | Review and manage confession submissions |
| Posts | Facebook page posts |
| Moderate | Moderator panel |
| User reports | Review and resolve reports |
| Online / Active users | Activity monitoring |
| Mappings | Manual user mapping |
| Create match | Manual match creation |
| Block user | Block users |
| Add warning | Send warnings to users |

See `@rc-agents/docs/admin-ecosystem.md` for the full admin stack description.

## Project structure

```
CVNLAdmin/
├── CVNLAdminApp.swift          # App entry point
├── Core/
│   ├── Config/                 # SERVER_URL, X-RC-Client header
│   ├── Models/                 # AdminUser, APIEnvelope, AuthTokens
│   ├── Auth/                   # AuthManager, TokenStore, UserRole
│   └── Networking/             # HTTPClient, AuthAPI
├── Features/
│   ├── Auth/                   # LoginView, LoginFormView, ForbiddenView
│   ├── Root/                   # RootView (auth router)
│   └── Home/                   # Post-login placeholder
└── Assets.xcassets/
Config/
├── Debug.xcconfig              # localhost server URL
├── Release.xcconfig            # production server URL
└── Info.plist                  # SERVER_URL, ATS for local dev
```

## Backend integration

- Base URL is configured per build configuration via xcconfig (`Config/Debug.xcconfig`, `Config/Release.xcconfig`).
- Auth uses the native client contract documented in `@rc-agents/docs/admin-native-auth.md`.
- iOS sends `X-RC-Client: ios` on all requests; refresh tokens are returned in JSON and stored in Keychain.
- Reuse rc-admin-server endpoints; do not reimplement moderation or user-management logic on device.
- Reference rc-admin-web API usage in `rc-admin-web/src/core/api/` when wiring new screens.

## Development

1. Open `CVNLAdmin.xcodeproj` in Xcode.
2. Start rc-admin-server locally (`npm run dev` in rc-admin-server).
3. Select a simulator or connected device.
4. Build and run (`Cmd+R`).

Debug builds use `http://localhost:8080/api`. Release builds use the production Heroku URL.

## Related documentation

- @rc-agents/docs/admin-ecosystem.md — admin stack overview
- @rc-agents/docs/admin-native-auth.md — native client auth contract (iOS + future Android)
- @rc-agents/AGENTS.md — project-wide agent rules
- @rc-admin-web — web admin client reference implementation
