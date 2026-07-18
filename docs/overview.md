# CVNL Admin iOS Overview

Native iOS admin app for **Random Chat** (CVNL / Seeyu). This project is the iOS counterpart to **rc-admin-web** and talks to **rc-admin-server**.

## Status

Early-stage SwiftUI app with auth infrastructure, login screen, Alerts & notifications, Confessions, and Posted to Facebook screens with shared top bar and hamburger menu navigation. Feature parity with rc-admin-web is the long-term goal.

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
│   ├── UI/                     # AdminTheme color tokens
│   ├── PostingSettingsStore.swift  # Local confession posting settings (UserDefaults)
│   └── Networking/             # HTTPClient, AuthAPI, AlertsAPI, FacebookAPI, ConfessionAPI
├── Features/
│   ├── Auth/                   # LoginView, LoginFormView, LoginBrandHeader, ForbiddenView
│   ├── Root/                   # RootView (auth router)
│   ├── Shell/                  # AdminTopBar, PostToFanPageSheet, PostingSettingsSheet, AdminMenuSheet, AdminDestination
│   ├── Alerts/                 # AlertsView + alert card components
│   ├── Confessions/            # ConfessionsView + filter, pagination, card components
│   ├── PostedToFacebook/       # PostedToFacebookView + page feed card components
│   └── Home/                   # Post-login shell (switches screens via menu)
└── Assets.xcassets/
Config/
├── Debug.xcconfig              # localhost server URL (simulator default)
├── Local.xcconfig.example      # template for physical device LAN IP
├── Release.xcconfig            # production server URL
└── Info.plist                  # SERVER_URL, ATS for local dev
```

## Backend integration

- Base URL is configured per build configuration via xcconfig (`Config/Debug.xcconfig`, `Config/Release.xcconfig`).
- Auth uses the native client contract documented in `@rc-agents/docs/admin-native-auth.md`.
- Each user has a single numeric role (`0` register, `1` admin, `2` moderator). Admin inherits moderator access.
- iOS sends `X-RC-Client: ios` on all requests; refresh tokens are returned in JSON and stored in Keychain.
- Reuse rc-admin-server endpoints; do not reimplement moderation or user-management logic on device.
- Reference rc-admin-web API usage in `rc-admin-web/src/core/api/` when wiring new screens.

## Development

1. Open `CVNLAdmin.xcodeproj` in Xcode.
2. Start rc-admin-server locally (`npm run dev` in rc-admin-server).
3. Select a simulator or connected device.
4. Build and run (`Cmd+R`).

Debug builds use `http://localhost:3000/api` on the simulator. Release builds use the production Heroku URL.

### Physical device

On a physical iPhone, `localhost` refers to the phone itself, not your Mac. To reach rc-admin-server on your machine:

1. Start rc-admin-server: `npm run dev` in rc-admin-server (port 3000).
2. Find your Mac's LAN IP: `ipconfig getifaddr en0` (use `en1` if on Ethernet/USB).
3. Copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig` and set your IP.
4. Ensure Mac and iPhone are on the **same Wi-Fi**.
5. Rebuild in Xcode (`Cmd+R`).

`Config/Local.xcconfig` is gitignored so each developer can use their own IP.

## Login screen

The login screen follows the CVNL Admin design mock (`rc-agents/docs/admin-app-standalone.html`):

- Brand header: purple "c" mark, "CVNL Admin", monospaced "confession console" subtitle
- Welcome copy and labeled username/password fields with purple focus ring
- Primary "Sign in" button (`#6E56CF`)
- Shared color tokens live in `CVNLAdmin/Core/UI/AdminTheme.swift`
- Password reset / forgot-password is intentionally **not** supported

## Alerts screen

The post-login screen follows the CVNL Admin design mock (`rc-agents/docs/admin-app-standalone-2.html`):

- **Admin only** — moderators see ForbiddenView after login
- Shared top bar: hamburger menu, screen title, compose, settings gear, purple user avatar initial
- Settings gear opens **Posting settings** (confessions posted so far, interval minutes, last posted at) — local until Confession publish lands on iOS
- Summary row: unacknowledged count chip and "Acknowledge all" action
- **App icon badge** syncs to the same unacknowledged count via `AppBadgeManager` (updates on load, push, foreground resume, and acknowledge; cleared on logout)
- Alert cards with severity chips (Critical / Warning / Info), acknowledge CTA, and acknowledged metadata
- Data from `GET /api/alerts`; acknowledge via `POST /api/alerts/:id/acknowledge` and `POST /api/alerts/acknowledge-all`
- Empty inbox shows "All caught up" until alerts are created server-side
- Default post-login screen; switch to other screens via the hamburger menu

## Confessions screen

The screen follows the CVNL Admin design mock (`mockups/Confession list (standalone).html`):

- **Admin only** — same gate as Alerts
- Shared top bar: hamburger menu, screen title, compose, settings gear, purple user avatar initial
- Status filter (All / Pending / Approved / Rejected) + reload, with offset pagination (page size 20)
- Cards show `#number` (editable), created time, content, and status-specific actions:
  - **Pending**: Reject / Approve (approve assigns next number from local `PostingSettingsStore.postedCount` when unset)
  - **Approved**: Approved chip + **Post to Facebook** (when numbered) via `PostToFanPageSheet` with web `buildPost` content
  - **Rejected**: Rejected chip
- Data from `GET /api/confessions`; updates via `POST /api/confessions/:id`
- Posted / Not posted chips are **not** shown (no `posted` field on the confession API)
- Approving/rejecting updates the card in place until reload or filter/page change
- Reachable from the hamburger menu (Alerts remains the default home screen)

## Posted to Facebook screen

The screen follows the CVNL Admin design mock (`mockups/Posted to Facebook (standalone).html`):

- **Admin only** — same gate as Alerts
- Shared top bar: hamburger menu, screen title, compose, settings gear, purple user avatar initial
- Card list of Facebook page posts with `#CVNL{number}` tag chip, full post body, posted time, and **View on page** button
- Data from `GET /api/facebook/getPageFeed` (same endpoint as rc-admin-web Posts page)
- **View on page** opens the Facebook permalink in Safari
- Pull-to-refresh reloads the feed
- Reachable from the hamburger menu (Alerts remains the default home screen)

## Shared top bar

`AdminTopBar` is used on all post-login screens:

- Hamburger opens the navigation menu
- Screen title
- Purple compose icon opens **Post to fan page** (`PostToFanPageSheet`) — publishes via `POST /api/facebook/postToPage` (optional schedule; updates `PostingSettingsStore.lastPostedAt`)
- Settings gear opens **Posting settings** (`PostingSettingsSheet`) — local UserDefaults via `PostingSettingsStore` (same fields as rc-admin-web header settings)
- Purple avatar with the user’s initial

## Navigation menu

The hamburger menu (`AdminMenuSheet`) lists:

1. Alerts & notifications
2. Confessions
3. Posted to Facebook
4. Logout

Selecting a screen dismisses the sheet and switches `HomeView` destination.

**Troubleshooting**

- Verify from Mac: `curl http://<your-ip>:3000/api/auth/login` (expect 401/400, not connection refused).
- macOS firewall: allow incoming connections for Node if prompted.
- If your IP changes (different network), update `Local.xcconfig`.

## Related documentation

- @rc-agents/docs/admin-ecosystem.md — admin stack overview
- @rc-agents/docs/admin-native-auth.md — native client auth contract (iOS + future Android)
- @rc-agents/AGENTS.md — project-wide agent rules
- @rc-admin-web — web admin client reference implementation
