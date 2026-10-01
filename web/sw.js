// Bump this version whenever publishing a new build.
const CACHE = 'merimemory-v1';
const CORE = ['./', 'index.html', 'flutter_bootstrap.js', 'flutter.js', 'main.dart.js', 'meri.js', 'manifest.json', 'assets/AssetManifest.bin', 'assets/FontManifest.json', 'assets/fonts/MaterialIcons-Regular.otf', 'assets/NOTICES', 'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm', 'icons/Icon-192.png', 'icons/Icon-512.png'];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(CORE)));
  self.skipWaiting();
});
self.addEventListener('activate', event => event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith('merimemory-') && key !== CACHE).map(key => caches.delete(key)))).then(() => self.clients.claim())));
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET' || new URL(event.request.url).origin !== location.origin) return;
  event.respondWith(fetch(event.request).then(response => {
    if (response.ok) { const copy = response.clone(); caches.open(CACHE).then(cache => cache.put(event.request, copy)); }
    return response;
  }).catch(() => caches.match(event.request).then(cached => cached || (event.request.mode === 'navigate' ? caches.match('index.html') : Response.error()))));
});
