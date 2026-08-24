<!-- Migrated from jitendrajangidcodes-cloud/AI-stuff:profiles/jitendrajangidcodes-cloud/repos/app-store-web/Learnings.md on 2026-08-22.
     Content is from the old knowledge system and predates this hub;
     verify against the working tree before relying on a specific claim. -->

# app-store-web — Learnings

Mistakes / setup gotchas specific to THIS repo. Fleet-wide gotchas live in
`~/.claude/Learnings.md` — reference them there, do not copy them here. The moment one of the
entries below recurs in a SECOND repo, move it to `~/.claude/Learnings.md`.

## The hub holds many apps — never use `releases/latest`
Because every app's APK is a Release in this one repo under its own app-id tag, `releases/latest`
resolves to whichever app released most recently, NOT a specific app. Both `sync-releases.sh` and
`build-manifest.mjs` read each app's own tag (`releases/tags/<id>`) for this reason, and any in-app
update-checker must do the same. Using `latest` silently serves the wrong app's APK.

## Direct-to-hub apps must be skipped in the mirror step
If an app's `apps.json` `repo` equals this hub repo, `sync-releases.sh` must NOT try to mirror it —
it publishes straight into the hub. A self-mirror would read the hub's own ambiguous
`releases/latest` (see above) and copy the wrong release. The `if [ "$repo" = "$HUB" ]` guard is
load-bearing; do not remove it when refactoring the script.

## `releases.json` is CI output — editing it by hand is pointless
The `sync-releases` workflow overwrites `releases.json` on every run (30-min cron + on relevant
push + manual dispatch). A hand edit is gone at the next tick. To change what the site/store shows,
change the underlying release or `apps.json` and let the workflow regenerate it.

## Manifest lag after a release is expected without a manual kick
The workflow's cron is every 30 minutes and GitHub often delays scheduled runs further, so the
website/store can show the OLD version for a while after a release. Trigger it explicitly
(`gh workflow run sync-releases.yml`) — the per-app `scripts/release.sh` already does this at the
end of a release. (The in-app update-checker reads the GitHub release directly and is not affected.)

## Version lives in the hub release NAME, not the tag
The tag is the stable app id (`reminder`, `cards`, …); the human version is the release NAME
(`<ver>` or `<ver>+<code>`). `build-manifest.mjs` parses the name for `version`/`versionCode`. If a
release is published with a wrong/empty name, the manifest version comes out wrong even though the
APK is correct.
