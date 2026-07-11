# CVNL Admin iOS Overview

Native iOS admin app for **Random Chat** (CVNL / Seeyu). This project is the iOS counterpart to **rc-admin-web** and talks to **rc-admin-server**.

## Status

Early-stage SwiftUI app. Feature parity with rc-admin-web is the long-term goal.

## Technology Stack

- **Language**: Swift
- **UI framework**: SwiftUI
- **IDE / build**: Xcode  (`CVNLAdmin.xcodeproj`)
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
├── CVNLAdminApp.swift    # App entry point
├── ContentView.swift     # Root view (placeholder)
└── Assets.xcassets/      # App icons and colors
```

As the app grows, organize by feature (e.g. `Features/Confessions/`, `Core/Networking/`, `Core/Auth/`).

## Backend integration

- Base URL and auth should follow the same contract as rc-admin-web (`VITE_SERVER_URL` equivalent for iOS).
- Reuse rc-admin-server endpoints; do not reimplement moderation or user-management logic on device.
- Reference rc-admin-web API usage in `rc-admin-web/src/core/api/` when wiring new screens.

## Development

1. Open `CVNLAdmin.xcodeproj` in Xcode.
2. Select a simulator or connected device.
3. Build and run (`Cmd+R`).

## Related documentation

- @rc-agents/docs/admin-ecosystem.md — admin stack overview
- @rc-agents/AGENTS.md — project-wide agent rules
- @rc-admin-web — web admin client reference implementation
