/* RAFORI Fantasy — cache léger de la page de jeu */
const RAFORI_CACHE = "rafori-fantasy-v32-shell-v2";
const APP_PATH = new URL("./index.html", self.location.href).pathname;

self.addEventListener("install", event => {
  self.skipWaiting();
});

self.addEventListener("activate", event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k.startsWith("rafori-fantasy-") && k !== RAFORI_CACHE).map(k => caches.delete(k)));
    await self.clients.claim();
  })());
});

self.addEventListener("fetch", event => {
  const request = event.request;
  if (request.method !== "GET") return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  if (!(request.mode === "navigate" || url.pathname === APP_PATH)) return;
  event.respondWith((async () => {
    const cache = await caches.open(RAFORI_CACHE);
    try {
      const response = await fetch(request);
      if (response && response.ok) cache.put(request, response.clone()).catch(() => {});
      return response;
    } catch (error) {
      const cached = await cache.match(request);
      if (cached) return cached;
      return new Response("RAFORI Fantasy est indisponible hors connexion. Reconnecte-toi puis recharge le jeu.", {
        status: 503,
        headers: { "Content-Type": "text/plain; charset=utf-8" }
      });
    }
  })());
});
