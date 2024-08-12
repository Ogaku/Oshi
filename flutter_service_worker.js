'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "4df526d8989cc68cf1faf0a0242d5e74",
".git/config": "601f32f888ae7fee1475a00e25375951",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "6a7ea3c9220410cf56d592366eb5fd58",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "b1a7fd8ff07c1458358b40b660eb808d",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "bd07577c9f10dc5772f882d84eca845e",
".git/logs/refs/heads/gh-pages": "bd07577c9f10dc5772f882d84eca845e",
".git/logs/refs/remotes/origin/auto-update-ai": "73ab786519077a02d8d55e4ac9f353a8",
".git/logs/refs/remotes/origin/auto-update-of": "513e2eee4b0e39fb44e9c107971e6b56",
".git/logs/refs/remotes/origin/gh-pages": "09be3de5c5cc41808e2f9a6938175073",
".git/logs/refs/remotes/origin/main": "174ea727c24f0877ea64b8b04e30d8ad",
".git/objects/06/5a156ad876ae75d08bca0aabc8c1e01f285abb": "1338ac20d12542d14345378e2fe2be26",
".git/objects/06/beebc999bca8174b2e89921d1a051d11a28c3b": "5413f2423665fcced9db2e7f078b9ac2",
".git/objects/08/0fecc2659d48beb5daba713274d0ac70008f37": "905a14430ee52429a58bf391017a6ed3",
".git/objects/08/ee80feb0d0924b750d0dbbcc36e8d28dbf61f9": "e4c88da1a7eb7af2942c528060f284f7",
".git/objects/0f/09d721b3f892ec2170d24a23cdff1c3f71764f": "c609a0bace98725f3aa92424350a4e10",
".git/objects/0f/c344c7e8b9e32ea1ad91f30ded22556352d7bf": "a8a30f28869f7378465338066f34d80d",
".git/objects/14/d25cb7617f9acb3f6752c0c137b87d311c1563": "875df52fa5e06b907c2e24a81623178c",
".git/objects/17/1abfc72c31ca692c3292b52ef2527e5fe3f6f4": "d023f87157801783f3f0d930af29df03",
".git/objects/18/eb401097242a0ec205d5f8abd29a4c5e09c5a3": "4e08af90d04a082aab5eee741258a1dc",
".git/objects/1d/dcf3e3abe766e7e3c8e8fe0cac5becf2964bd9": "f9b3f04186eb1224e31a7ebd78094aa1",
".git/objects/20/1afe538261bd7f9a38bed0524669398070d046": "82a4d6c731c1d8cdc48bce3ab3c11172",
".git/objects/20/cb2f80169bf29d673844d2bb6a73bc04f3bfb8": "b807949265987310dc442dc3f9f492a2",
".git/objects/24/9873f4a8b342cae7cf7165c91727a6f6418898": "19c20ed9b10e89297634da29bc490dc4",
".git/objects/26/44320fea0c61dca7027e57bafed8555f406ff9": "52753a9456eec4095a73e9eb2027adef",
".git/objects/2c/72e952172fc61cf5282d766bdce52163896d37": "9d78dc26e1cb823c7f83ca3d9fa77867",
".git/objects/2c/adbdd0f08546c72f0d02fddc1f14a2449a9c8d": "bb5c6a598480d9b55d1c309adf7d7b8a",
".git/objects/2d/0471ef9f12c9641643e7de6ebf25c440812b41": "d92fd35a211d5e9c566342a07818e99e",
".git/objects/3b/b0860a0981211a1ab11fced3e6dad7e9bc1834": "3f00fdcdb1bb283f5ce8fd548f00af7b",
".git/objects/3d/29838223cb71747e18002a45c6f38799849359": "db24dc7d9e65fc17c31a8d378241e04f",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/49/adebdb511c8c293b28db3f6792e5bac28cdc32": "ba6a3971e7f06834fd6ec3844372ce17",
".git/objects/52/7ba50044ba78d2b3cfddada59e0e97e74a478d": "df6b3e820dd04fa28cd92bcfb90509c9",
".git/objects/56/10f641b458212fcf66a2bfa7fefda345a8b31c": "8d06fbd050d2ec6ef598174232f151f1",
".git/objects/58/356635d1dc89f2ed71c73cf27d5eaf97d956cd": "f61f92e39b9805320d2895056208c1b7",
".git/objects/58/b007afeab6938f7283db26299ce2de9475d842": "6c6cbea527763bb3cdff2cecfee91721",
".git/objects/60/cfee8716754c67f3a6148c8f15541adf10410d": "b5caa3912cc969b9515f7bbcc121cf1f",
".git/objects/62/c89ee094658c7a9465824fdb42793a64ea557b": "133cd5da638f245b079d9e9cdc29ae38",
".git/objects/6d/00170c07f6c0b447cfd97b24b6fb6985cad9e3": "2a43797fb20dffde3892b97864c76e33",
".git/objects/6d/6d06e974b6d45898397b7b2734b7616e318db0": "4998aaa85a9722fffe35495f7725ee9e",
".git/objects/71/3f932c591e8f661aa4a8e54c32c196262fd574": "66c6c54fbdf71902cb7321617d5fa33c",
".git/objects/73/b8e55fc547d47671128fea93f77d380296d2f4": "01308c2031b6a158621580c51ed811f4",
".git/objects/7a/83cbcaa522e8371c12ef7935d96e78df302376": "29768285739cdb3015356226fe2fa29d",
".git/objects/83/fdba30175cdf619f37fd557b8af992b9156fb6": "a845d1b88aa5ba4b5a32d0ac459eed4a",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/94/f7d06e926d627b554eb130e3c3522a941d670a": "77a772baf4c39f0a3a9e45f3e4b285bb",
".git/objects/a7/d9410ce853c88408268d76e2d0f3e8148e514a": "85590917483cf5e8c4b2e7b14d0cc9cf",
".git/objects/b3/ebbd38f666d4ffa1a394c5de15582f9d7ca6c0": "23010709b2d5951ca2b3be3dd49f09df",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/c2/d772aa5549276c92e1be0942261735deef68a5": "8fd41b4032af5bd377a60819cf52c4d1",
".git/objects/c7/7663172ca915a99a594ca17d06f527db05657d": "6335b074b18eb4ebe51f3a2c609a6ecc",
".git/objects/c9/5303fc05fe96ad79a86d77647583a84fc96775": "57f68cdbbdd948353c7866ec7753f17e",
".git/objects/c9/bf8af1b92c723b589cc9afadff1013fa0a0213": "632f11e7fee6909d99ecfd9eeab30973",
".git/objects/cf/4aa6e4064bd2b652f1f019ca81bf0ba7925e63": "35b4961cb02049dc8e8d457497a20db4",
".git/objects/d1/098e7588881061719e47766c43f49be0c3e38e": "f17e6af17b09b0874aa518914cfe9d8c",
".git/objects/d2/971a372041051f042c19a4b8dca5e55b51d049": "ac582485c600fd9cfc8dab7377d3315e",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/db/a0e94bd69801b0f310cda9bb201bae685a2e55": "c5f2f258fd8070833ddc9e91a2635647",
".git/objects/dd/501afdfe7d27261c61f1508f34a551693fa15a": "68b0e1cdd44af58906468515a5e3d888",
".git/objects/e7/f21124b15531ef699c54650cef7bb70f12f696": "ecd18c2709d71286fc5ef6f19e756f0d",
".git/objects/e8/4bcf2d8aa991482012fa74bcf2959e082464d3": "f1493dfe15fa1269ec388bc94de6582e",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ef/50e9f5dad91053967be4ddbab5a960243b5d29": "7f085918ff03386fd9a9ec7e37ddc174",
".git/objects/f0/da7b5f128801cbfc1b9f9fd051b07f34970928": "2a9a26b61041d0b8048ca119c87d04f8",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f7/9f51c8d6181ba53ccc20ff4f27701a8ad7f675": "283f5ecb8d8d9a755176268350b6c2ea",
".git/objects/fb/ac5d02a1a63d877a4f84b39bfefa4913aa1c16": "3cf94809bcd116e7cd07eed3bea4917d",
".git/objects/fe/b923193313be2c33af92df86fc627fc96aa89c": "48d3914d107178d5a36ac94eb3d8b760",
".git/objects/pack/pack-528be249b34fcf5272a7415cfac05e1d61edf56b.idx": "90080dfa7e42a78ebf70dadb2e6a7523",
".git/objects/pack/pack-528be249b34fcf5272a7415cfac05e1d61edf56b.pack": "532e2514a51f567b2dce27c8a85a5801",
".git/objects/pack/pack-528be249b34fcf5272a7415cfac05e1d61edf56b.rev": "e156ce9dec29810db160d25ac3d23f81",
".git/refs/heads/gh-pages": "7c525768d42e4ea96fc3bc4914703ea0",
".git/refs/remotes/origin/auto-update-ai": "1ba31b71614eed56a76847d97d3c838a",
".git/refs/remotes/origin/auto-update-of": "9f4ab058fded0bbc3273d27eb0cffbad",
".git/refs/remotes/origin/gh-pages": "7c525768d42e4ea96fc3bc4914703ea0",
".git/refs/remotes/origin/main": "c5486ded436825f7cf5db1a47dfc2e02",
".git/refs/tags/1.0.20231121.102": "3ab97fec34616ce1ce465a5a149a45d1",
".git/refs/tags/1.0.20231122.104": "a6c463b54caa9a2590d27d4bb9246d81",
".git/refs/tags/1.0.20231122.105": "a5e741addb5f960f935ebe0ebecb60fa",
".git/refs/tags/1.0.20231122.106": "03bff8fb45245fe53bb8d4025fa5173c",
".git/refs/tags/1.0.20231122.108": "7dcc3cc64babf0650fa6b41f14b744c3",
".git/refs/tags/1.0.20231122.109": "1ce85b26f0b33cf58562d7ca2933ae76",
".git/refs/tags/1.0.20231122.110": "9e8afef7dc2861709644b83f88e798d7",
".git/refs/tags/1.0.20231122.111": "9e8afef7dc2861709644b83f88e798d7",
".git/refs/tags/1.0.20231122.114": "94a9c0ea98d121d56910b0ccfce1a4fb",
".git/refs/tags/1.0.20231122.115": "169723d1324cf28c6c3596afc1b00fd6",
".git/refs/tags/1.0.20231123.116": "2b1082bc40183765cd924732f0114037",
".git/refs/tags/1.0.20231123.117": "2b1082bc40183765cd924732f0114037",
".git/refs/tags/1.0.20231123.118": "658d2ed011bc162d78d688cf23f5e36e",
".git/refs/tags/1.0.20231124.10": "bf3208fdd500bd2b9f9c6f2825ead7a1",
".git/refs/tags/1.0.20231124.11": "6af389c5300372e7f365af57279e7ccf",
".git/refs/tags/1.0.20231124.119": "32874ab94d19545d59d4c9b697cd511c",
".git/refs/tags/1.0.20231124.120": "0f11da5c3875146ca5cdb981cb85495e",
".git/refs/tags/1.0.20231124.123": "4901fa4d552a5c76c0eeaff2a6faad14",
".git/refs/tags/1.0.20231124.124": "9014638253e1829bc81ccaccffc76cb2",
".git/refs/tags/1.0.20231124.8": "79c258d88c1b8e85cf3977399e5bf932",
".git/refs/tags/1.0.20231124.9": "6d63030933b348f10771112b957b8ce3",
".git/refs/tags/1.0.20231125.1": "409dee9b1d96aa379fd4c769e837be98",
".git/refs/tags/1.0.20231126.1": "a39e500954dd5b35abdf42051ae95a7d",
".git/refs/tags/1.0.20231126.2": "bb4efe681d01dd30329ab8488baa2baa",
".git/refs/tags/1.0.20231126.3": "bf13421c1fbffbc245a4efe8ac7c8a44",
".git/refs/tags/1.0.20231126.4": "5505c8d9dd5eba44c7e83ab788d72d25",
".git/refs/tags/1.0.20231126.5": "ab9c91fd72de70a7f10dd63af62369e3",
".git/refs/tags/1.0.20231126.6": "e1cea8f3f384736bf00761a98837b846",
".git/refs/tags/1.0.20231127.1": "4eaa312fc9a9951ed825f8f8d1387f29",
".git/refs/tags/1.0.20231128.1": "b938c730139aff5f0bbf7c655d000e7f",
".git/refs/tags/1.0.20231128.2": "338a12e9ce1fdc099345071d9195830f",
".git/refs/tags/1.0.20231128.3": "2d86519636b09a6f169e796e39a01399",
".git/refs/tags/1.0.20231128.4": "e5dbc2ba67927b513f687b7131e6a5a5",
".git/refs/tags/1.0.20231128.5": "8e2462b9e6aa2ae06424ac8ad901933c",
".git/refs/tags/1.0.20231202.1": "af858bb19dba91bf3944a9c8a570aba7",
".git/refs/tags/1.0.20231202.2": "e4b0c529aa178f5bb7612065f957960f",
".git/refs/tags/1.0.20231202.3": "f1e1c0de07df8b2777b50889e5610fe2",
".git/refs/tags/1.0.20231202.4": "b600c9e3e24e5bd4c0318d13ae694710",
".git/refs/tags/1.0.20231205.1": "cba6593dc6ff28a296e1677dece43f93",
".git/refs/tags/1.0.20231210.1": "836edf4262604789f0382bd8fba41453",
".git/refs/tags/1.0.20231211.1": "8b8385718e4d613cbd6c3de35a5dfb76",
".git/refs/tags/1.0.20231212.1": "73d49324770bd398839a32dc907f8078",
".git/refs/tags/1.0.20231212.2": "79989568dbfbeea2b7a3842b53926512",
".git/refs/tags/1.0.20231212.3": "f2d52ec4e353419d37d41bb0c7868abe",
".git/refs/tags/1.0.20231219.1": "e974bff57203e2dc05fa86b898e1183a",
".git/refs/tags/1.0.20231219.2": "8ac5097252aeba013d8bc186f65869ee",
".git/refs/tags/1.0.20231220.4": "ab493e02425cbe910b4b04f86d2234ff",
".git/refs/tags/1.0.20231221.1": "cd28483b4a3708810ab7bb8f36184fe1",
".git/refs/tags/1.0.20231222.1": "cd28483b4a3708810ab7bb8f36184fe1",
".git/refs/tags/1.0.20231222.2": "cd28483b4a3708810ab7bb8f36184fe1",
".git/refs/tags/1.0.20240107.1": "2d8bf7978354b219d8837b567939e653",
".git/refs/tags/1.0.20240107.2": "66e0d51ef2b316696dec900c31bcc617",
".git/refs/tags/1.0.20240120.1": "5c057523cb768cbc376d73e7317daf19",
".git/refs/tags/1.0.20240206.1": "125a146f19af9a1c447e04b0c4ded364",
".git/refs/tags/1.0.20240207.1": "12505e880b3be65e0b9d826bc3b34c7d",
".git/refs/tags/1.0.20240226.1": "a799e31c0d1b848794feb478e7464dab",
".git/refs/tags/1.0.20240227.1": "cb4923cfa5de90f83f3f9d059b89a6b5",
".git/refs/tags/1.0.20240302.2": "a876db0e66484cda8dad5cdcd49bb53f",
".git/refs/tags/1.0.20240303.1": "6913e0e9bb6c23bf4e7306f05bc102ce",
".git/refs/tags/1.0.20240304.1": "f127c6b6961e5a3da1c7f433f2d2130c",
".git/refs/tags/1.0.20240307.1": "ff7776640a6721b44e2cb4df3f4071ae",
".git/refs/tags/1.0.20240323.1": "174285499aa2efefba96914d25833e63",
".git/refs/tags/1.0.20240323.2": "6bb0838a21e0237c8ed138cfb77d7c0e",
".git/refs/tags/1.0.20240327.1": "b92326c264dc2625933502151ccbed36",
".git/refs/tags/1.0.20240525.6": "b227bc60133b8d5aef84d40206d64862",
".git/refs/tags/1.0.20240613.1": "9fe6b08d0abd8a7c1538045a43779514",
".git/refs/tags/1.0.20240614.1": "c5486ded436825f7cf5db1a47dfc2e02",
"assets/AssetManifest.bin": "d593a3f13366a923eb67e055ddccde7e",
"assets/AssetManifest.bin.json": "c614b4621527650a19ccf5012b0d54b6",
"assets/AssetManifest.json": "f5d4b59491fb536f3668fcbf5a5da84a",
"assets/assets/resources/strings/en.json": "744208c5c5929af1743ee4bce5f4bafe",
"assets/assets/resources/strings/ja.json": "b6b08b6395ef0ef2027bfeb9228e8a49",
"assets/assets/resources/strings/locales.json": "c85281f176db9a9639ea6f0eafa1ddce",
"assets/assets/resources/strings/pl.json": "3c8fd8ad239b4264aedc90559c30bc94",
"assets/assets/resources/strings/uw.json": "120ffa65f86b521611ff6cc5ffec5bc1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "59575064167ef8f0e8355de4a73c3d83",
"assets/NOTICES": "96071b36004a12fa47b11c2941544aa1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "f24fe0d48678226611d4888c43fcc951",
"assets/packages/fluttertoast/assets/toastify.css": "910ddaaf9712a0b0392cf7975a3b7fb5",
"assets/packages/fluttertoast/assets/toastify.js": "18cfdd77033aa55d215e8a78c090ba89",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "6591984c8ae42728ad9f1e0a5be49bb8",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"flutter_bootstrap.js": "7ebbf8c727f2c51633640ad35a13914b",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "e676d9a489fcd0388dc508e5fa193404",
"/": "e676d9a489fcd0388dc508e5fa193404",
"main.dart.js": "57c0ac80a09e4d99ab999935f77099fe",
"manifest.json": "ef20b7bf54aa51dae3d4c2729cf6f04c",
"splash/img/dark-1x.png": "6591984c8ae42728ad9f1e0a5be49bb8",
"splash/img/dark-2x.png": "065325202c5047eff0f38910b6716abf",
"splash/img/dark-3x.png": "95d0773a2054905e8ef977f4c4045da0",
"splash/img/dark-4x.png": "cc6c8c11cb2f859b76dbd6e9f1b71e13",
"splash/img/light-1x.png": "6591984c8ae42728ad9f1e0a5be49bb8",
"splash/img/light-2x.png": "065325202c5047eff0f38910b6716abf",
"splash/img/light-3x.png": "95d0773a2054905e8ef977f4c4045da0",
"splash/img/light-4x.png": "cc6c8c11cb2f859b76dbd6e9f1b71e13",
"version.json": "31410f9e331e460300c7db77598e3403"};
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
