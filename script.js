const THEME_KEY = "theme";
const THEME_EXPLICIT_KEY = "theme-explicit";

function currentTheme() {
  return document.documentElement.getAttribute("data-theme") || "dark";
}

function applyTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
}

function toggleTheme() {
  const next = currentTheme() === "dark" ? "light" : "dark";
  localStorage.setItem(THEME_KEY, next);
  localStorage.setItem(THEME_EXPLICIT_KEY, "1");
  applyTheme(next);
}

window.matchMedia("(prefers-color-scheme: light)").addEventListener("change", (e) => {
  if (localStorage.getItem(THEME_EXPLICIT_KEY) === "1") return;
  applyTheme(e.matches ? "light" : "dark");
});

document.addEventListener("DOMContentLoaded", () => {
  const btn = document.querySelector(".theme-toggle");
  if (btn) btn.addEventListener("click", toggleTheme);
});

async function fetchLatestRelease(repo) {
  try {
    const res = await fetch(`https://api.github.com/repos/${repo}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
    });
    if (!res.ok) return null;
    const data = await res.json();
    const asset = (data.assets || [])[0];
    return {
      version: (data.tag_name || "").replace(/^v/, ""),
      notes: data.body || "",
      publishedAt: data.published_at || null,
      downloadUrl: asset ? asset.browser_download_url : null,
      sizeBytes: asset ? asset.size : null,
    };
  } catch (e) {
    return null;
  }
}

function formatSize(bytes) {
  if (!bytes) return "--";
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function formatDate(iso) {
  if (!iso) return "--";
  return new Date(iso).toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
}

async function loadApps() {
  const res = await fetch("apps.json");
  return res.json();
}
