# Important

**Always** read @rc-agents/AGENTS.md first.

For admin stack context, read @rc-agents/docs/admin-ecosystem.md.

## Project role

**rc-admin-app-ios** is the native iOS admin client for Random Chat (CVNL / Seeyu). It provides the same admin functionality as **rc-admin-web**, backed by **rc-admin-server**.

When adding features, mirror rc-admin-web behavior and reuse rc-admin-server APIs. Do not duplicate business logic in the iOS app.

## Stack

- **Language**: Swift
- **UI**: SwiftUI
- **Build**: Xcode (`CVNLAdmin.xcodeproj`)
- **Backend**: rc-admin-server HTTP API

## Architecture

Read @rc-admin-app-ios/docs/overview.md before making structural changes.

## Conventions

- Prefer small, focused Swift files and SwiftUI views.
- Split views into separate files when they grow beyond ~200 lines.
- Use Swift naming conventions (`PascalCase` for types, `camelCase` for properties and methods).
- Keep networking and auth in dedicated modules; views should not embed raw URL construction.
- Match rc-admin-web feature naming and user flows where possible.

## Verification

- Build in Xcode: `Cmd+B`
- Run on simulator or device: `Cmd+R`
- Add XCTest unit/UI tests as features are implemented

## Commit messages

Follow @rc-agents/AGENTS.md. Use `docs:` for documentation and an admin-specific prefix when appropriate (e.g. `admin:`).
