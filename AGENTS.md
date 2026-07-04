# AGENTS.md — app-store

Personal app catalog (GitHub Pages) plus a Flutter Android "store" app that installs
and updates the listed apps.

## Layout
- `index.html` / `app.html` / `script.js` / `style.css` — the static website
- `apps.json` — the ONE source of truth: every listed app. Adding an entry here makes it
  appear on the website AND in the store app. Never add an app anywhere else.
- `releases.json` — generated in CI; latest version + APK url per app. Do not hand-edit.
- `scripts/build-manifest.mjs` — regenerates `releases.json` from `apps.json` + Releases.
- `store-app/` — Flutter Android store app. Fetches apps.json + releases.json from the
  live site and installs/updates apps via the system installer.

## Conventions
- Design tokens (colors, fonts, animations) are defined once in `style.css` `:root`
  blocks; the Flutter app mirrors them in `store-app/lib/theme/`. Keep the two in sync.
- Release tags use Flutter versioning `v<name>+<code>` (e.g. `v1.2.3+45`) so the manifest
  can carry a numeric versionCode. Name-only tags still work (semver fallback).
- No credentials in the repo. CI uses the built-in `GITHUB_TOKEN` only.

## Verify
- Manifest: `node scripts/build-manifest.mjs` (needs network) then inspect `releases.json`.
- Flutter: `cd store-app && flutter analyze && flutter build apk --debug`.
