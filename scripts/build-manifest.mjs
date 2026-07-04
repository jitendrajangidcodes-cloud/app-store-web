// Regenerates releases.json from apps.json + each app's GitHub Releases.
// Run in CI (see .github/workflows/manifest.yml) or locally with network.
// GITHUB_TOKEN is optional; when set it lifts the API rate limit to 5000/hr.
// No secrets are written to output — only public release metadata.

import { readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const token = process.env.GITHUB_TOKEN || "";

const headers = {
  Accept: "application/vnd.github+json",
  "X-GitHub-Api-Version": "2022-11-28",
  ...(token ? { Authorization: `Bearer ${token}` } : {}),
};

// Flutter tags as v<name>+<code>. Split so the store can compare numeric
// versionCode when present, and fall back to semver name otherwise.
function parseTag(tag) {
  const raw = (tag || "").replace(/^v/, "");
  const [name, code] = raw.split("+");
  return { version: name || raw, versionCode: code ? Number(code) : null };
}

async function fetchLatest(repo) {
  const res = await fetch(`https://api.github.com/repos/${repo}/releases/latest`, { headers });
  if (!res.ok) return null;
  const data = await res.json();
  const asset = (data.assets || []).find((a) => a.name.endsWith(".apk")) || (data.assets || [])[0];
  const { version, versionCode } = parseTag(data.tag_name);
  return {
    version,
    versionCode,
    notes: data.body || "",
    publishedAt: data.published_at || null,
    apkUrl: asset ? asset.browser_download_url : null,
    sizeBytes: asset ? asset.size : null,
  };
}

const apps = JSON.parse(await readFile(join(root, "apps.json"), "utf8"));
const out = { generatedAt: new Date().toISOString(), apps: {} };

for (const app of apps) {
  try {
    const rel = await fetchLatest(app.repo);
    if (rel) out.apps[app.id] = rel;
    else console.warn(`no release for ${app.id} (${app.repo})`);
  } catch (e) {
    console.warn(`failed ${app.id}: ${e.message}`);
  }
}

await writeFile(join(root, "releases.json"), JSON.stringify(out, null, 2) + "\n");
console.log(`wrote releases.json for ${Object.keys(out.apps).length}/${apps.length} apps`);
