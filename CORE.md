# app-store-web — Core

## What this is

The public **app-store HUB** for every personal Android app in the fleet. It is three things in
one repo:

1. A static **GitHub Pages website** (`store.pnsjy.in`) that lists and links installs for each app.
2. The **`apps.json` / `releases.json`** data pair — `apps.json` is the hand-maintained catalog
   (source of truth for what is listed); `releases.json` is the CI-generated manifest of the
   latest version + hub APK URL per app.
3. The **release hub** itself — every app's APK is published here as a GitHub Release under a
   stable per-app tag (tag == the app's `id`). The website, the native PNSJY Store Flutter app
   (source in `app-store-android-private`/`-pub`), and that app's self-update all read from this
   one repo.

Distribution is centralized here so the site and the store app always reflect the latest shipped
version within one CI tick, with no cross-repo token and no edits to the individual app repos.
Full fleet-level mechanics: `~/.claude/CORE.md` → "App Release Distribution".

## Tech Stack

- **Website:** vanilla HTML/CSS/JS — `index.html` (catalog), `app.html` (per-app detail),
  `script.js`, `style.css`. No framework, no build step.
- **PWA:** `manifest.json` + `sw.js` (network-passthrough, no caching — exists only for
  installability).
- **Data:** static JSON (`apps.json` maintained by hand, `releases.json` generated).
- **Manifest generation:** Node (`scripts/build-manifest.mjs`, ESM) + Bash
  (`scripts/sync-releases.sh`), run by GitHub Actions.
- **Hosting:** GitHub Pages (custom domain `store.pnsjy.in` via `CNAME`, `.nojekyll`).
- **Feedback backend:** external Cloudflare Worker (`app-store-feedback.jitendrajangid-codes.workers.dev`)
  that files GitHub issues; spam-guarded by Cloudflare Turnstile + honeypot + KV rate-limit.
  Worker source is backed up in a separate private repo — not in this repo.

## Project Files

| File / Dir | Purpose |
|------------|---------|
| `apps.json` | Source of truth for the catalog — one object per listed app (schema below). |
| `releases.json` | GENERATED manifest: latest version, notes, hub APK URL + size per app. Never hand-edit. |
| `index.html` | Catalog page. |
| `app.html` | Per-app detail page. |
| `script.js` | Site logic: reads `releases.json` (live GitHub API fallback), renders cards/detail, store CTA. |
| `style.css` | All styling + design tokens in `:root` (mirrored by the Flutter app's `lib/theme/`). |
| `feedback.js` | In-site feedback modal → posts to the Worker → files a GitHub issue. Turnstile + honeypot. |
| `manifest.json`, `sw.js` | PWA install support. |
| `scripts/sync-releases.sh` | Mirrors each app's latest source-repo APK into this hub under the app-id tag. Idempotent. |
| `scripts/build-manifest.mjs` | Rebuilds `releases.json` from THIS repo's hub Releases (version from release name). |
| `scripts/download-log/` | Apps Script + Sheet download logger (Code.gs + README) — no credential in the repo. |
| `.github/workflows/sync-releases.yml` | Runs mirror + manifest rebuild + commits `releases.json`. |
| `assets/icons/` | 512px per-app icons + PWA icons. `assets/brand/pnsjy-mark.png` is the company mark. |
| `assets/screenshots/` | Per-app screenshots the site + store app render live (currently reminder only). |
| `CNAME`, `.nojekyll` | GitHub Pages custom domain + Jekyll-off. |
| `RELEASE.md` | Changelog of the HUB REPO ITSELF (website/scripts) — not any app's APK releases. |

### `apps.json` schema (one object per app)

| Field | Meaning |
|-------|---------|
| `id` | Stable slug; also the hub release TAG and the `releases.json` key. |
| `name`, `tagline`, `category` | Display name, one-line pitch, catalog category. |
| `beta` | Boolean — drives the BETA badge, independent of `category`. |
| `platform` | e.g. `"Android"`. |
| `color` | Accent hex for the card/detail. |
| `requiresAccount` | Boolean — whether the app needs a sign-in. |
| `icon` | Path to the app icon under `assets/icons/`. |
| `repo` | The app's SOURCE/release repo. If it equals this hub repo, the app publishes direct-to-hub (no mirror). Otherwise it is a mirrored `-pub` repo. |
| `packageId` | Android application id (used by the store app for installed-version checks). |
| `about`, `requirements` | Long description + install prerequisites shown on the detail page. |
| `screenshots` | Array of `{ src, alt }` (may be empty). |

### `releases.json` schema (GENERATED — `{ generatedAt, apps: { <id>: {…} } }`)

Per app: `version`, `versionCode` (numeric if the hub release name is `<ver>+<code>`, else `null`),
`notes` (release body), `publishedAt`, `apkUrl` (hub download URL), `sizeBytes`.

### `sync-releases` workflow (how a release reaches the site + store)

Triggers: push to `main` touching `apps.json`/`sync-releases.sh`/`build-manifest.mjs`/the workflow
file; a `*/30 * * * *` cron; or manual `workflow_dispatch`. One job, `contents: write`, built-in
`GITHUB_TOKEN` only, `concurrency: sync-releases`:

1. `scripts/sync-releases.sh` — for each app in `apps.json`: if its `repo` equals the hub, skip
   (already published direct-to-hub — a self-mirror would read the hub's ambiguous
   `releases/latest`). Otherwise read the source repo's `releases/latest`, and if the hub's release
   for that tag is a different version, download the `.apk` asset and re-publish it into the hub
   under the app-id tag (title = source version, notes = source body). Idempotent: same version =
   no bytes moved.
2. `scripts/build-manifest.mjs` — reads each app's own hub tag directly and regenerates
   `releases.json` (version parsed from the release NAME `<ver>[+<code>]`).
3. Commits `releases.json` only if it changed.

Because APKs and the manifest live in the same repo, a mirror + rebuild happen in the same run, so
a new source release propagates within one tick. The in-app update-checker reads the GitHub
release directly and is NOT gated on this; the website/store manifest IS.

## Architecture — Critical Rules

- **`apps.json` is the only place an app gets listed.** Never add an app to the site, the store
  app, or `releases.json` directly.
- **`releases.json` is generated output** — regenerate it via the workflow/scripts, never edit by
  hand.
- **A hub release tag == the app's `id`.** In-app update-checkers must query that specific tag
  (`releases/tags/<id>`), never `releases/latest` — the hub holds many apps and `latest` resolves
  to whichever released most recently.
- **Public repo: zero credentials.** Keystore + `key.properties` gitignored; CI uses only the
  built-in token; the Turnstile site key + Worker URL are public by design, the secret lives only
  in Cloudflare.
- **Design tokens live once in `style.css` `:root`** and are mirrored by the Flutter store app.

## Features

Authoritative registry. Add an entry BEFORE building. Never remove entries — mark final status.
Status: `BUILT-AWAITING-VERIFY` / `VERIFIED` / `PENDING USER DECISION` / `NOT BUILDING`.
Migrated from the former `features.md` + `progress.txt`; historical per-phase build notes live in
git history.

### F1 — App catalog from `apps.json`
Website lists every app defined in `apps.json`, with per-app detail pages.
*Status: VERIFIED*

### F2 — Live version / download / release-notes per app
Site shows the latest version, download link, size, and notes, read from `releases.json` (single
fetch) with a live GitHub API fallback when the manifest is stale/uncached.
*Status: BUILT-AWAITING-VERIFY*

### F3 — Light/dark theme, glass + glow design
Theme toggle persisted in `localStorage`; glass/glow visual system.
*Status: VERIFIED*

### F4 — PWA install support
`manifest.json` + `sw.js` + an "Install app" button in the topbar, shown on `beforeinstallprompt`
and hidden after install/dismiss (index + app pages).
*Status: BUILT-AWAITING-VERIFY*

### F5 — Explicit BETA badge
Card ribbon + detail badge driven by the `apps.json` `"beta"` flag, decoupled from `category`.
*Status: BUILT-AWAITING-VERIFY*

### F6 — Single-repo hub (this repo hosts every APK)
All app + store APKs mirrored into this repo's Releases under stable app-id tags; the `sync-releases`
workflow mirrors + rebuilds the manifest in one run; website, store app, and store self-update all
read from this one repo; no cross-repo token; app build repos untouched.
*Status: BUILT-AWAITING-VERIFY*

### F7 — Direct-to-hub publishing pattern
An app whose `apps.json` `repo` equals this hub publishes its release straight into the hub's
Releases (no separate `-pub` mirror repo); `sync-releases.sh` skips the mirror step for it.
Reminder + Cards remain mirrored (they have their own `-pub` repos); ai-scanner, mirrordrive,
twinclean, localsender are direct-to-hub.
*Status: BUILT-AWAITING-VERIFY*

### F8 — Direct in-site feedback → auto-filed GitHub issue
In-site modal (`feedback.js`) posts to the Cloudflare Worker, which files a GitHub issue — no
GitHub account/login for the user. Spam guarded by Turnstile + honeypot + KV rate-limit. Falls
back to a prefilled-issue link if the Worker/Turnstile is unreachable.
*Status: BUILT-AWAITING-VERIFY*

### F9 — Download logging (optional, disclosed)
Apps Script Web App appends one row per first-time download/install to a private Google Sheet
(name, optional email, app, platform, device/browser info). No credential in the repo; scoped to
the store surface only. Source + setup in `scripts/download-log/`.
*Status: BUILT-AWAITING-VERIFY*

### F10 — "Get the PNSJY Store app" CTA
Featured banner/CTA on the site linking the native store app's own hub release (`store` tag).
*Status: BUILT-AWAITING-VERIFY*

### F11 — Star ratings
Per-app user ratings.
*Status: NOT BUILDING — needs a database/Firebase; deferred by decision.*
