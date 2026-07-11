# rc-admin-app-ios

Native iOS admin app for **Random Chat** (CVNL / Seeyu).

This project mirrors **rc-admin-web** and connects to **rc-admin-server** for moderation, user management, and other admin operations.

## Getting started

1. Open `CVNLAdmin.xcodeproj` in Xcode.
2. Start rc-admin-server locally (`npm run dev` in rc-admin-server).
3. Select a simulator or device.
4. Build and run (`Cmd+R`).

### Physical device

On a physical iPhone, `localhost` does not reach your Mac. Copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig`, set your Mac's LAN IP (`ipconfig getifaddr en0`), and rebuild. See @rc-admin-app-ios/docs/overview.md for full steps.

## Documentation

- @rc-admin-app-ios/docs/overview.md — project architecture
- @rc-admin-app-ios/AGENTS.md — agent and development rules
- @rc-agents/docs/admin-ecosystem.md — admin stack overview

## Related repos

| Repo | Role |
|------|------|
| rc-admin-server | Admin API and background jobs |
| rc-admin-web | Admin web dashboard (reference UI) |
