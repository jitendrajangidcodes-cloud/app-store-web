// In-site feedback: a small modal that posts to the feedback Worker, which
// files a GitHub issue on the user's behalf. No GitHub account, no login. If
// the Worker or Turnstile is unreachable, the modal falls back to the old
// prefilled-issue link so feedback is never a dead end.
//
// TURNSTILE_SITE_KEY is public by design (the secret half lives in the Worker).

const FEEDBACK_ENDPOINT = "https://app-store-feedback.jitendrajangid-codes.workers.dev/submit";
const TURNSTILE_SITE_KEY = "0x4AAAAAADxd8GGj3y3tQ51H";

const FB_TYPES = [
  { type: "suggestion", label: "Suggest", placeholder: "What would you like to see?" },
  { type: "bug", label: "Report a bug", placeholder: "What happened? Steps to reproduce, device / Android version." },
  { type: "feedback", label: "Feedback", placeholder: "Your feedback…" },
];

let fbState = { app: null, type: "feedback", widgetId: null, sending: false };

function buildFeedbackModal() {
  const overlay = document.createElement("div");
  overlay.className = "fb-overlay";
  overlay.hidden = true;
  overlay.innerHTML = `
    <div class="fb-modal" role="dialog" aria-modal="true" aria-labelledby="fb-title">
      <button class="fb-close" type="button" aria-label="Close">&times;</button>
      <h3 id="fb-title">Send feedback</h3>
      <p class="fb-sub">Goes straight to the developer — no GitHub account needed.</p>
      <div class="fb-types">${FB_TYPES.map(
        (t, i) => `<button type="button" class="fb-type${i === 2 ? " active" : ""}" data-type="${t.type}">${t.label}</button>`
      ).join("")}</div>
      <textarea class="fb-message" rows="5" maxlength="5000" placeholder="Your feedback…"></textarea>
      <input class="fb-email" type="email" maxlength="200" placeholder="Email (optional, if you want a reply)">
      <input class="fb-hp" type="text" tabindex="-1" autocomplete="off" aria-hidden="true">
      <div class="fb-turnstile"></div>
      <div class="fb-status" role="status"></div>
      <div class="fb-actions">
        <a class="fb-fallback" target="_blank" rel="noopener">Prefer GitHub? Open an issue</a>
        <button class="fb-send" type="button">Send</button>
      </div>
    </div>`;
  document.body.appendChild(overlay);
  wireFeedbackModal(overlay);
  return overlay;
}

function wireFeedbackModal(overlay) {
  overlay.querySelector(".fb-close").addEventListener("click", closeFeedbackModal);
  overlay.addEventListener("click", (e) => { if (e.target === overlay) closeFeedbackModal(); });
  overlay.querySelector(".fb-send").addEventListener("click", submitFeedback);
  overlay.querySelectorAll(".fb-type").forEach((btn) =>
    btn.addEventListener("click", () => selectType(overlay, btn.dataset.type))
  );
}

function fbOverlay() {
  return document.querySelector(".fb-overlay") || buildFeedbackModal();
}

function selectType(overlay, type) {
  fbState.type = type;
  const cfg = FB_TYPES.find((t) => t.type === type);
  overlay.querySelectorAll(".fb-type").forEach((b) => b.classList.toggle("active", b.dataset.type === type));
  overlay.querySelector(".fb-message").placeholder = cfg.placeholder;
  refreshFallback(overlay);
}

function refreshFallback(overlay) {
  // feedbackUrl + FEEDBACK_REPO come from script.js (loaded first).
  overlay.querySelector(".fb-fallback").href = feedbackUrl(fbState.type, fbState.app);
}

function openFeedbackModal(app) {
  fbState.app = app || null;
  const overlay = fbOverlay();
  const titleApp = app ? ` on ${app.name}` : "";
  overlay.querySelector("#fb-title").textContent = `Send feedback${titleApp}`;
  overlay.querySelector(".fb-message").value = "";
  overlay.querySelector(".fb-email").value = "";
  overlay.querySelector(".fb-hp").value = "";
  setStatus(overlay, "", "");
  selectType(overlay, "feedback");
  overlay.hidden = false;
  document.body.style.overflow = "hidden";
  renderTurnstile(overlay);
  overlay.querySelector(".fb-message").focus();
}

function closeFeedbackModal() {
  const overlay = document.querySelector(".fb-overlay");
  if (!overlay) return;
  overlay.hidden = true;
  document.body.style.overflow = "";
  if (window.turnstile && fbState.widgetId !== null) turnstile.reset(fbState.widgetId);
}

function renderTurnstile(overlay) {
  const holder = overlay.querySelector(".fb-turnstile");
  if (!window.turnstile) { holder.hidden = true; return; }
  holder.hidden = false;
  if (fbState.widgetId !== null) { turnstile.reset(fbState.widgetId); return; }
  fbState.widgetId = turnstile.render(holder, { sitekey: TURNSTILE_SITE_KEY });
}

function turnstileToken() {
  if (window.turnstile && fbState.widgetId !== null) return turnstile.getResponse(fbState.widgetId);
  return "";
}

async function submitFeedback() {
  if (fbState.sending) return;
  const overlay = document.querySelector(".fb-overlay");
  const message = overlay.querySelector(".fb-message").value.trim();
  if (!message) { setStatus(overlay, "Please type a message first.", "err"); return; }

  const token = turnstileToken();
  if (window.turnstile && !token) { setStatus(overlay, "Please complete the verification.", "err"); return; }

  setSending(overlay, true);
  try {
    const res = await postFeedback(message, overlay, token);
    if (res && res.ok) {
      setStatus(overlay, "Thanks — your feedback was sent.", "ok");
      overlay.querySelector(".fb-message").value = "";
      setTimeout(closeFeedbackModal, 1400);
    } else {
      setStatus(overlay, "Could not send. Use the GitHub link below instead.", "err");
    }
  } catch {
    setStatus(overlay, "Network error. Use the GitHub link below instead.", "err");
  } finally {
    setSending(overlay, false);
    if (window.turnstile && fbState.widgetId !== null) turnstile.reset(fbState.widgetId);
  }
}

function postFeedback(message, overlay, token) {
  return fetch(FEEDBACK_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      type: fbState.type,
      message,
      email: overlay.querySelector(".fb-email").value.trim(),
      appName: fbState.app ? fbState.app.name : "",
      appId: fbState.app ? fbState.app.id : "",
      website: overlay.querySelector(".fb-hp").value,
      turnstileToken: token,
    }),
  }).then((r) => r.json());
}

function setSending(overlay, sending) {
  fbState.sending = sending;
  const btn = overlay.querySelector(".fb-send");
  btn.disabled = sending;
  btn.textContent = sending ? "Sending…" : "Send";
}

function setStatus(overlay, text, kind) {
  const el = overlay.querySelector(".fb-status");
  el.textContent = text;
  el.className = `fb-status${kind ? " " + kind : ""}`;
}

document.addEventListener("click", (e) => {
  const trigger = e.target.closest("[data-feedback-open]");
  if (!trigger) return;
  e.preventDefault();
  const app = trigger.dataset.appId
    ? { id: trigger.dataset.appId, name: trigger.dataset.appName || "" }
    : null;
  openFeedbackModal(app);
});

document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeFeedbackModal();
});
