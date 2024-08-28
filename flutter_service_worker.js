'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"splash/img/light-1x.png": "6591984c8ae42728ad9f1e0a5be49bb8",
"splash/img/light-2x.png": "065325202c5047eff0f38910b6716abf",
"splash/img/dark-3x.png": "95d0773a2054905e8ef977f4c4045da0",
"splash/img/light-3x.png": "95d0773a2054905e8ef977f4c4045da0",
"splash/img/dark-1x.png": "6591984c8ae42728ad9f1e0a5be49bb8",
"splash/img/dark-2x.png": "065325202c5047eff0f38910b6716abf",
"splash/img/dark-4x.png": "cc6c8c11cb2f859b76dbd6e9f1b71e13",
"splash/img/light-4x.png": "cc6c8c11cb2f859b76dbd6e9f1b71e13",
"icons/Icon-maskable-512.png": "4ed83c840b00925d42841ea2bc79d0e5",
"icons/Icon-192.png": "a24e88ffd876941c4ef49583bfda9467",
"icons/Icon-512.png": "8e8406e5b0ba557379cb113e065031bf",
"icons/Icon-maskable-192.png": "51aa6032c4da098345d54661c10d4e57",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "8ff4040e429c70306375e6dad4ef7212",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/assets/resources/strings/en.json": "e87a893d984377996a5c61bae50c7b6f",
"assets/assets/resources/strings/uw.json": "120ffa65f86b521611ff6cc5ffec5bc1",
"assets/assets/resources/strings/pl.json": "3abf7f249c1239a380fcf1bb12086cf6",
"assets/assets/resources/strings/locales.json": "5502f2aaa771d68153b12a050b4be73b",
"assets/assets/resources/strings/de.json": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/resources/strings/ja.json": "a65d2466d5ee00a391a15108546a37b0",
"assets/assets/resources/images/logo_fit.png": "236b90359ccad3e3369e0bf0d25a5b19",
"assets/assets/resources/images/logo_ios.png": "a9c8258c8eefb6c1d18cd508cb0ff6ef",
"assets/assets/resources/images/logo.png": "a8f30906a961e415839d6f5fc307428d",
"assets/fonts/MaterialIcons-Regular.otf": "ce55d2fdd0362977e1d4deb066217796",
"assets/AssetManifest.bin": "a0ac77c20704a7ce7e59d68acf0173f5",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "3a4369ba6df08fcf69a6da2e6e6dd5cf",
"assets/packages/fluttertoast/assets/toastify.js": "18cfdd77033aa55d215e8a78c090ba89",
"assets/packages/fluttertoast/assets/toastify.css": "910ddaaf9712a0b0392cf7975a3b7fb5",
"assets/AssetManifest.json": "5d578a80fd148d5211d9ca7b9f5e60a8",
"assets/NOTICES": "782c40745a9629acc9e4af9322cc5465",
"index.html": "fc6c5a753f38f72becb5ca79be5c53fe",
"/": "fc6c5a753f38f72becb5ca79be5c53fe",
"main.dart.js": "3c8009623e97ef0ea8a316e05e6a127b",
"favicon.png": "6591984c8ae42728ad9f1e0a5be49bb8",
"version.json": "33042dea67290db231da6e08f3bfec62",
"flutter_bootstrap.js": "e81236d0c79767db755dfd7cc4cd4a3c",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"manifest.json": "8c30e3c10ecc9d8edb757d6cb6dc52c3",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
