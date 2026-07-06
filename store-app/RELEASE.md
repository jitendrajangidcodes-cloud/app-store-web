# Releases

Distribution: this app has no separate source repo -- it lives inside the
`app-store` hub itself and publishes straight to the hub's own GitHub
Releases under the stable tag `store` (see `../AGENTS.md`). Self-update reads
that same tag directly (`lib/services/self_update.dart` / `lib/config.dart`).

## v1.0.5+6 (2026-07-06)

- Download logging (introduced inactive in v1.0.4) is now live: the Apps
  Script endpoint is deployed and wired into `LogService._endpoint`. Verified
  working end-to-end (Python `requests` POST returned `{"ok":true}`) after
  fixing a real bug in the script itself (`LockService` acquisition ran
  outside its try/catch, so any failure there returned Google's generic
  error page instead of a usable response) -- see
  `../scripts/download-log/Code.gs` history.

- Hub: https://github.com/jitendrajangidcodes-cloud/app-store/releases/tag/store

## v1.0.4+5 (2026-07-05)

- Fixed the install popup silently failing to appear: `installApk()` fired
  the install intent blind, never checking `canRequestPackageInstalls()`
  first. If that permission wasn't already granted, Android blocked with its
  own warning screen instead of the real install prompt. Now checks first,
  and if not granted, shows an "Open Settings" prompt and auto-retries the
  install handoff on app resume.
- Fixed downloaded APKs being deleted if the app closed before install:
  `cleanupApks()` wiped every `.apk` in the cache dir on every launch and
  every screen navigation. Now only sweeps files untouched for 15+ minutes.
- Downloads now resume via HTTP Range requests after a network drop or a
  Wi-Fi/mobile-data switch, instead of restarting from byte 0; reuses an
  already-complete file outright instead of re-fetching it.
- Download failures now show a Retry action instead of a dead-end snackbar.
- Added an optional download log (name + device info, once per device) for
  the web + store app surfaces only -- inactive until the Apps Script
  endpoint is deployed and wired in (see `../scripts/download-log/README.md`).

- Hub: https://github.com/jitendrajangidcodes-cloud/app-store/releases/tag/store

## v1.0.3+4 (2026-07-04)

- Update button now shows live download progress and reports errors (no more
  dead-looking tap)
- Single, cleaner brand header on the home screen
- Pull-to-refresh updates in place instead of flashing like a web reload
- Installs every app and its own updates from the one hub

- Hub: https://github.com/jitendrajangidcodes-cloud/app-store/releases/tag/store
