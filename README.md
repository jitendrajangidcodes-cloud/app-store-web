# Jitendra — App Store

**Live site: https://store.pnsjy.in**

A personal catalog of apps built by Jitendra, browsable and installable directly — no store
review, no accounts. There is also a native **PNSJY Store** Android app that installs and
updates every listed app like an app store, and keeps itself up to date.

## Single-repo hub

This repository is the one public hub for distribution. Every APK — each listed app plus the
store app itself — is published here as a GitHub Release under a stable tag (e.g. `reminder`,
`cards`, `store`). The website, the store app, and the store's self-update all read from this
one repo, and `releases.json` is regenerated here whenever a new build is mirrored in — so the
site and the store always reflect the latest shipped version.

Distribution is centralized, but **security is not compromised**: CI only ever writes this repo
using the built-in token, reads the source repos unauthenticated, and the signing keystore and
its `key.properties` are gitignored and never committed. No tokens, credentials, or logins live
in the repo.

New apps are never added automatically — an app is only listed when explicitly added to
`apps.json`. See `AGENTS.md` for the full layout and release flow.

## Download reliability & security (fleet-wide)

Every app in the family — the PNSJY Store itself, Reminder, Cards, AI Scanner, TwinClean —
downloads its own updates through Android's `DownloadManager` rather than an in-app HTTP stream,
with a persisted download id so a transfer interrupted by the app being backgrounded or killed is
resumed/re-attached instead of re-downloaded from zero, and an already-fully-downloaded matching
version is reused rather than re-fetched. Each app validates the downloaded APK's package name and
version before handing it to the system installer; Android's own installer additionally refuses to
install an update signed by a different key than what's already installed, which is the real
backstop against a tampered APK. Reminder, TwinClean, and the PNSJY Store also run a periodic
background check that posts a notification when an update is found — the actual download/install
always still goes through an explicit user tap on the system installer, since Android does not let
a third-party app (store or not) install silently.

Google Drive was considered as a faster host for these APKs and rejected: Drive share links
throttle and break under real traffic (per-file download quotas, virus-scan interstitials on
popular files) and were never built as a CDN, unlike GitHub Releases' asset delivery (Fastly-backed,
supports HTTP Range/resume) that this hub already uses. Drive stays a personal-backup destination
only, never a distribution channel for this hub.
