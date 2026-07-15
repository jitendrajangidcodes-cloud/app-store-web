# AGENTS.md — app-store-web

Personal app catalog + release hub (GitHub Pages, served at `store.pnsjy.in`). The
companion Flutter Android "PNSJY Store" app lives in its own repos
(`app-store-android-private` / `-pub`) and is distributed through this hub.

Global agent rules are NOT repeated here — they live in `~/.claude/` (`CLAUDE.md`,
`AGENTS.md`, `known-mistakes.md`). This file holds only what is specific to this repo.

## Layout
- `index.html` / `app.html` / `script.js` / `style.css` — the static website
- `apps.json` — the ONE source of truth: every listed app (its `repo` is the build/source
  repo). Adding an entry here makes it appear on the website AND in the store app. Never add
  an app anywhere else.
- `releases.json` — generated in CI; latest version + hub APK url per app. Do not hand-edit.
- `scripts/sync-releases.sh` — mirrors each app's latest source APK into THIS repo's Releases.
- `scripts/build-manifest.mjs` — regenerates `releases.json` from THIS repo's hub Releases.
- Store app source now lives in separate repos: `app-store-android-private` (real signing
  key committed) and `app-store-android-pub` (sanitized public mirror). This repo only
  hosts the website + release hub; it no longer contains `store-app/`.

## Single-repo hub (how releases flow)
- This repo is the ONE public hub. Every APK — `reminder`, `cards`, `ai-scanner`, `twinclean`,
  and the store app itself (`store`) — is published as a Release here under a stable tag equal
  to that name.
  The human version lives in the release NAME; the APK is the release asset.
- The website, the store app, and the store's self-update ALL read from this repo. Because the
  APKs and `releases.json` live together, `.github/workflows/sync-releases.yml` mirrors + rebuilds
  the manifest in one run (30-min cron + manual + on relevant push), so a new source release
  propagates within one tick. No cross-repo token; app build repos are never modified.
- To ship a new store build: build it in `app-store-android-private` (`flutter build apk
  --release`), then publish the APK to the `store` tag here (title = `<name>+<code>`). Keep a
  bridge copy in the legacy `pnsjy-store` repo only until every install has moved past `1.0.0+1`.

## Two release patterns (per app, set by `apps.json`'s `repo` field)
1. **Mirrored** (`reminder`, `cards` historically) — the app has its own separate public
   `<name>-pub` repo as the release source of truth; `scripts/sync-releases.sh` copies its
   latest release into this hub under the app's id tag. Needed only when the app's `-pub` repo
   also serves another purpose (e.g. Reminder's Google OAuth consent-screen homepage/privacy
   policy) or an in-app update-checker already points at that repo's API.
2. **Direct-to-hub** (`ai-scanner`, and the simplified default for new apps) — the app's private
   source repo publishes its release straight to THIS repo under the app's id tag (no `-pub`
   repo exists at all). Set `apps.json`'s `repo` field to `jitendrajangidcodes-cloud/app-store-web`
   for these — `sync-releases.sh` detects `repo == HUB` and skips the mirror step (a self-mirror
   would otherwise read the hub's own `releases/latest`, which is ambiguous across multiple
   apps' tags). `build-manifest.mjs` needs no change either way — it always reads the app's own
   tag directly from the hub, regardless of how the release got there.
- Prefer direct-to-hub for any new app with no OAuth-homepage or existing update-checker
  dependency — one fewer repo to create and keep in sync.

## Conventions
- Design tokens (colors, fonts, animations) are defined once in `style.css` `:root`
  blocks; the Flutter app (in `app-store-android-private`) mirrors them in its
  `lib/theme/`. Keep the two in sync.
- An app's BETA badge (site card ribbon + detail-page badge) is driven by an explicit
  `"beta": true|false` field in `apps.json`, independent of `category`. Historically it
  keyed off `category === "Beta"` — `index.html` and `app.html` now read `app.beta`.
- Hub release NAME carries the version as `<name>+<code>` (e.g. `1.2.3+45`) so the manifest
  can carry a numeric versionCode. Name-only still works (semver fallback).
- No credentials in the repo. CI uses the built-in `GITHUB_TOKEN` only (writes THIS repo,
  reads source repos unauthenticated). Keystore + `key.properties` are gitignored; never commit.

## Verify
- Mirror + manifest: `bash scripts/sync-releases.sh && node scripts/build-manifest.mjs`
  (needs network + gh auth) then inspect `releases.json`.
- Flutter store app: verified in its own repo (`app-store-android-private`), not here.
