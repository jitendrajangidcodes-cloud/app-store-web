// Deliberately no caching: releases.json and APK assets must always be fetched
// fresh. This worker exists only so the browser considers the site installable.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
self.addEventListener("fetch", (event) => {
  event.respondWith(fetch(event.request));
});
