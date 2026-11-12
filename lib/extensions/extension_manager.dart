import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:d4rt/d4rt.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:oshi/extensions/bridge/oshi_bridge.dart';
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/extensions/runtime/dart_extension_provider.dart';
import 'package:oshi/extensions/runtime/standalone_calendar_provider.dart';
import 'package:oshi/share/appcenter.dart' show Version;
import 'package:oshi/share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

class ExtensionManager extends ChangeNotifier {
  static final ExtensionManager instance = ExtensionManager._();
  ExtensionManager._();

  static const String officialRepoUrl = 'https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json';
  static const String foxMirrorRepoUrl = 'https://raw.githubusercontent.com/Ogaku/Oshi/FOX/extensions_repo/index.json';
  static const String officialRepoWebsite = 'https://github.com/Ogaku/Oshi-Extensions';

  final Map<String, ExtensionManifest> _installed = {};
  final List<ExtensionRepo> _repositories = [];
  final List<ExtensionManifest> _available = [];
  bool _initialized = false;
  bool _isLoadingCatalog = false;
  String? _lastCatalogError;

  Map<String, ExtensionManifest> get installed => Map.unmodifiable(_installed);
  List<ExtensionRepo> get repositories => List.unmodifiable(_repositories);
  List<ExtensionManifest> get available => List.unmodifiable(_available);
  bool get isLoadingCatalog => _isLoadingCatalog;
  String? get lastCatalogError => _lastCatalogError;

  bool isInstalled(String id) => _installed.containsKey(id);

  ExtensionManifest? getInstalled(String id) => _installed[id];

  bool hasUpdate(ExtensionManifest remote) {
    final local = _installed[remote.id];
    if (local == null) return false;
    return Version.parse(remote.version) > Version.parse(local.version);
  }

  int get updatesCount => _available.where(hasUpdate).length;

  /// Loads repositories and installed extensions from Hive & disk, and syncs `Share.providers`.
  Future<void> initialize() async {
    if (_initialized) {
      syncShareProviders();
      return;
    }

    try {
      final box = await Hive.openBox('extensions');

      // 1. Load repositories
      _repositories.clear();
      final rawRepos = box.get('repositories');
      if (rawRepos is String && rawRepos.isNotEmpty) {
        final decoded = jsonDecode(rawRepos);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              _repositories.add(ExtensionRepo.fromJson(item.cast<String, dynamic>()));
            }
          }
        }
      }
      if (_repositories.isEmpty) {
        _repositories.add(const ExtensionRepo(
          name: 'Oshi Official Extensions',
          url: officialRepoUrl,
          website: officialRepoWebsite,
          isOfficial: true,
          enabled: true,
        ));
      }

      // 2. Load installed extensions
      _installed.clear();
      final rawInstalled = box.get('installed');
      if (rawInstalled is String && rawInstalled.isNotEmpty) {
        final decoded = jsonDecode(rawInstalled);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              var manifest = ExtensionManifest.fromJson(item.cast<String, dynamic>());
              if ((manifest.sourceCode == null || manifest.sourceCode!.isEmpty) && !kIsWeb) {
                final diskCode = await _readScriptFromDisk(manifest.id);
                if (diskCode != null) {
                  manifest = manifest.copyWith(sourceCode: diskCode);
                }
              }
              if (manifest.id.isNotEmpty && (manifest.sourceCode?.isNotEmpty ?? false)) {
                _installed[manifest.id] = manifest;
              }
            }
          }
        }
      }
      // 3. Pre-populate available from bundled catalog if available is empty
      if (_available.isEmpty) {
        final bundled = await _loadBundledCatalog();
        _available.addAll(bundled);
      }
    } catch (e, st) {
      debugPrint('[ExtensionManager] initialize error: $e\n$st');
    }

    _initialized = true;
    syncShareProviders();
    notifyListeners();
  }

  /// Synchronizes `Share.providers` with the currently installed extensions.
  void syncShareProviders() {
    Share.providers.clear();
    Share.providers[StandaloneCalendarProvider.guid] = (
      instance: StandaloneCalendarProvider(),
      factory: () => StandaloneCalendarProvider(),
    );
    for (final entry in _installed.entries) {
      final manifest = entry.value;
      Share.providers[entry.key] = (
        instance: DartExtensionProvider(manifest: manifest),
        factory: () => DartExtensionProvider(manifest: _installed[entry.key] ?? manifest),
      );
    }

    // Also update any active sessions in memory so their `provider` instance uses the loaded extension
    try {
      for (final session in Share.settings.sessions.sessions.values) {
        final reg = Share.providers[session.providerGuid];
        if (reg != null && session.provider is UninstalledExtensionProvider) {
          session.provider = reg.factory();
        }
      }
    } catch (_) {}
  }

  /// Ensures that any existing user sessions saved before the extension system was introduced
  /// automatically have their provider extension installed on first launch.
  Future<void> ensureSessionProvidersInstalled() async {
    await initialize();

    final neededGuids = <String>{
      for (final entry in Share.settings.sessions.sessions.entries)
        if (entry.key != 'SESSIONS-SHIM-SMPL-FAKE-DATAPROVIDER' &&
            entry.value.providerGuid.isNotEmpty &&
            entry.value.providerGuid != 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER')
          entry.value.providerGuid,
    };

    final missing = neededGuids.where((id) => !_installed.containsKey(id)).toSet();
    if (missing.isEmpty) return;

    debugPrint('[ExtensionManager] Auto-installing providers for existing sessions: $missing');
    if (_available.isEmpty) {
      await refreshCatalog();
    }

    for (final guid in missing) {
      ExtensionManifest? candidate;
      for (final ext in _available) {
        if (ext.id == guid) {
          candidate = ext;
          break;
        }
      }
      candidate ??= await _loadBundledManifestById(guid);
      if (candidate != null) {
        try {
          await installExtension(candidate);
        } catch (e) {
          debugPrint('[ExtensionManager] Failed to auto-install $guid: $e');
        }
      }
    }
  }

  /// Resolves user-provided URLs (GitHub repo links, `oshi://add-repo?...` deep links, raw JSON, or `.dart` URLs).
  ({String url, String? name}) normalizeRepoInput(String rawInput, {String? customName}) {
    var trimmed = rawInput.trim();
    String? inferredName = customName?.trim();

    // Handle `oshi://add-repo?repo_name=...&repo_url=...` or `mangayomi://add-repo?...`
    if (trimmed.startsWith('oshi://') || trimmed.startsWith('mangayomi://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        inferredName ??= uri.queryParameters['repo_name'];
        final repoUrl = uri.queryParameters['repo_url'] ?? uri.queryParameters['url'];
        if (repoUrl != null && repoUrl.isNotEmpty) {
          trimmed = repoUrl.trim();
        }
      }
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.toLowerCase() == 'github.com') {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length == 2) {
        // https://github.com/Owner/Repo -> raw index.json
        final owner = segments[0];
        final repo = segments[1].replaceAll(RegExp(r'\.git$'), '');
        inferredName ??= '$owner/$repo';
        trimmed = 'https://raw.githubusercontent.com/$owner/$repo/main/index.json';
      } else if (segments.length >= 4 && (segments[2] == 'blob' || segments[2] == 'tree')) {
        final owner = segments[0];
        final repo = segments[1];
        final branch = segments[3];
        final rest = segments.skip(4).join('/');
        inferredName ??= '$owner/$repo ($branch)';
        trimmed = rest.isEmpty
            ? 'https://raw.githubusercontent.com/$owner/$repo/$branch/index.json'
            : (rest.endsWith('.json') || rest.endsWith('.dart')
                ? 'https://raw.githubusercontent.com/$owner/$repo/$branch/$rest'
                : 'https://raw.githubusercontent.com/$owner/$repo/$branch/$rest/index.json');
      }
    }

    if (inferredName == null || inferredName.isEmpty) {
      final parsed = Uri.tryParse(trimmed);
      if (parsed != null && parsed.pathSegments.length >= 2) {
        inferredName = parsed.host == 'raw.githubusercontent.com'
            ? '${parsed.pathSegments[0]}/${parsed.pathSegments[1]}'
            : parsed.host;
      } else {
        inferredName = 'Custom Repository';
      }
    }

    return (url: trimmed, name: inferredName);
  }

  /// Adds a repository URL (or direct `.dart` script URL), fetches it immediately to verify it works, and saves.
  Future<({bool success, String? message, int count})> addRepository(String rawInput, {String? customName}) async {
    await initialize();
    final resolved = normalizeRepoInput(rawInput, customName: customName);
    if (resolved.url.isEmpty || Uri.tryParse(resolved.url) == null) {
      return (success: false, message: 'Invalid repository URL.', count: 0);
    }

    try {
      final items = await fetchCatalogFromUrl(resolved.url);
      final existingIdx = _repositories.indexWhere((r) => r.url.toLowerCase() == resolved.url.toLowerCase());
      final repo = ExtensionRepo(
        name: resolved.name ?? 'Custom Repository',
        url: resolved.url,
        isOfficial: resolved.url == officialRepoUrl,
        enabled: true,
      );
      if (existingIdx >= 0) {
        _repositories[existingIdx] = repo;
      } else {
        _repositories.add(repo);
      }
      await _saveState();
      await refreshCatalog();
      return (success: true, message: null, count: items.length);
    } catch (e) {
      return (success: false, message: '$e', count: 0);
    }
  }

  Future<void> removeRepository(String url) async {
    _repositories.removeWhere((r) => r.url == url);
    await _saveState();
    await refreshCatalog();
  }

  Future<void> toggleRepository(String url, bool enabled) async {
    final idx = _repositories.indexWhere((r) => r.url == url);
    if (idx < 0) return;
    _repositories[idx] = _repositories[idx].copyWith(enabled: enabled);
    await _saveState();
    await refreshCatalog();
  }

  Future<void> resetDefaultRepository() async {
    if (!_repositories.any((r) => r.url == officialRepoUrl)) {
      _repositories.insert(
        0,
        const ExtensionRepo(
          name: 'Oshi Official Extensions',
          url: officialRepoUrl,
          website: officialRepoWebsite,
          isOfficial: true,
          enabled: true,
        ),
      );
      await _saveState();
    }
    await refreshCatalog();
  }

  /// Fetches and parses a single repository index URL (or single `.dart` extension script URL).
  Future<List<ExtensionManifest>> fetchCatalogFromUrl(String url) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.plain,
      headers: const {'User-Agent': 'Oshi-App'},
    ));

    // Direct single-file `.dart` extension script URL
    if (url.toLowerCase().endsWith('.dart')) {
      final res = await dio.get<String>(url);
      final script = res.data ?? '';
      if (script.trim().isEmpty) throw Exception('Empty .dart extension file at $url');
      return [_parseManifestFromDartHeader(script, url)];
    }

    String? rawJson;
    if (url == officialRepoUrl) {
      // Try official repo -> FOX branch mirror -> bundled asset fallback
      for (final candidateUrl in [officialRepoUrl, foxMirrorRepoUrl]) {
        try {
          final res = await dio.get<String>(candidateUrl);
          if (res.statusCode == 200 && (res.data?.trim().isNotEmpty ?? false)) {
            rawJson = res.data;
            break;
          }
        } catch (_) {}
      }
      rawJson ??= await rootBundle.loadString('assets/resources/extensions/index.json');
    } else {
      try {
        final res = await dio.get<String>(url);
        rawJson = res.data;
      } catch (e) {
        // If user entered a GitHub repo that uses `master` instead of `main`, try `master`
        if (url.contains('/main/index.json')) {
          final masterUrl = url.replaceFirst('/main/index.json', '/master/index.json');
          final res = await dio.get<String>(masterUrl);
          rawJson = res.data;
        } else {
          rethrow;
        }
      }
    }

    if (rawJson == null || rawJson.trim().isEmpty) {
      throw Exception('Empty response from $url');
    }

    final decoded = jsonDecode(rawJson);
    final list = decoded is List
        ? decoded
        : (decoded is Map && decoded['extensions'] is List
            ? decoded['extensions'] as List
            : (decoded is Map && decoded['providers'] is List ? decoded['providers'] as List : const []));

    final manifests = <ExtensionManifest>[];
    for (final item in list) {
      if (item is Map) {
        final m = ExtensionManifest.fromJson(item.cast<String, dynamic>(), repoUrl: url);
        if (m.id.isNotEmpty && m.sourceCodeUrl.isNotEmpty) {
          manifests.add(m);
        }
      }
    }
    return manifests;
  }

  /// Refreshes the combined catalog from all enabled repositories.
  Future<void> refreshCatalog() async {
    await initialize();
    _isLoadingCatalog = true;
    _lastCatalogError = null;
    notifyListeners();

    final merged = <String, ExtensionManifest>{};
    String? firstError;

    for (final repo in _repositories.where((r) => r.enabled)) {
      try {
        final list = await fetchCatalogFromUrl(repo.url);
        for (final item in list) {
          final existing = merged[item.id];
          if (existing == null || Version.parse(item.version) > Version.parse(existing.version)) {
            merged[item.id] = item;
          }
        }
      } catch (e) {
        firstError ??= '${repo.name}: $e';
      }
    }

    _available
      ..clear()
      ..addAll(merged.values);
    _isLoadingCatalog = false;
    _lastCatalogError = firstError;
    notifyListeners();
  }

  /// Downloads, verifies, compiles in `d4rt`, and installs an extension.
  Future<void> installExtension(ExtensionManifest manifest) async {
    await initialize();
    final sourceCode = await _downloadExtensionScript(manifest);
    if (sourceCode.trim().isEmpty) {
      throw Exception('Downloaded extension source code is empty.');
    }

    // Optional SHA-256 verification (supports both raw and LF-normalized line endings)
    if (manifest.sha256 != null && manifest.sha256!.trim().isNotEmpty) {
      final actualRawHash = sha256.convert(utf8.encode(sourceCode)).toString().toLowerCase();
      final actualLfHash =
          sha256.convert(utf8.encode(sourceCode.replaceAll('\r\n', '\n'))).toString().toLowerCase();
      final expectedHash = manifest.sha256!.trim().toLowerCase();
      if (actualRawHash != expectedHash && actualLfHash != expectedHash) {
        throw Exception('SHA-256 mismatch for ${manifest.localizedName} (expected $expectedHash, got $actualLfHash).');
      }
    }

    final installedManifest = manifest.copyWith(
      sourceCode: sourceCode,
      installedAt: DateTime.now(),
    );

    // Dry-run compile/init in d4rt to verify the script is valid before registering
    final testProvider = DartExtensionProvider(manifest: installedManifest);
    // Accessing credentialsConfig and providerName is immediate; also verify script parses in D4rt
    final testD4rt = D4rt(enableAstCache: true);
    OshiBridge.register(testD4rt, OExtensionHostContext());
    testD4rt.execute(source: sourceCode, positionalArgs: [OSource.fromManifest(installedManifest)]);
    if (testProvider.providerName.isEmpty) {
      throw Exception('Invalid extension metadata.');
    }

    if (!kIsWeb) {
      await _writeScriptToDisk(installedManifest.id, sourceCode);
    }

    _installed[installedManifest.id] = installedManifest;
    syncShareProviders();
    await _saveState();
    notifyListeners();
    try {
      Share.refreshAll.broadcast();
    } catch (_) {}
  }

  /// Uninstalls an extension by its provider GUID.
  Future<void> uninstallExtension(String id) async {
    await initialize();
    _installed.remove(id);
    if (!kIsWeb) {
      await _deleteScriptFromDisk(id);
    }
    syncShareProviders();
    await _saveState();
    notifyListeners();
    try {
      Share.refreshAll.broadcast();
    } catch (_) {}
  }

  Future<String> _downloadExtensionScript(ExtensionManifest manifest) async {
    if (manifest.sourceCode != null && manifest.sourceCode!.trim().isNotEmpty) {
      return manifest.sourceCode!;
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.plain,
      headers: const {'User-Agent': 'Oshi-App'},
    ));

    final candidateUrls = <String>[manifest.sourceCodeUrl];
    if (manifest.id == 'PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA') {
      candidateUrls.add('https://raw.githubusercontent.com/Ogaku/Oshi-Extension-Librus/main/extension.dart');
      candidateUrls.add('https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/dart/librus/librus.dart');
    } else if (manifest.id == 'PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI') {
      candidateUrls.add('https://raw.githubusercontent.com/Ogaku/Oshi-Extension-Vulcan/main/extension.dart');
      candidateUrls.add('https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/dart/vulcan/vulcan.dart');
    } else if (manifest.id == 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER') {
      candidateUrls.add('https://raw.githubusercontent.com/Ogaku/Oshi-Extension-Sample/main/extension.dart');
      candidateUrls.add('https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/dart/sample/sample.dart');
    }

    for (final url in candidateUrls) {
      try {
        final res = await dio.get<String>(url);
        if (res.statusCode == 200 && (res.data?.trim().isNotEmpty ?? false)) {
          return res.data!;
        }
      } catch (_) {}
    }

    // Offline / pre-release bundled fallback for official extensions
    final bundledAsset = switch (manifest.id) {
      'PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA' => 'assets/resources/extensions/librus.dart',
      'PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI' => 'assets/resources/extensions/vulcan.dart',
      'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER' => 'assets/resources/extensions/sample.dart',
      _ => null,
    };
    if (bundledAsset != null) {
      return await rootBundle.loadString(bundledAsset);
    }

    throw Exception('Failed to download extension from ${manifest.sourceCodeUrl}');
  }

  Future<List<ExtensionManifest>> _loadBundledCatalog() async {
    try {
      final raw = await rootBundle.loadString('assets/resources/extensions/index.json');
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((item) => ExtensionManifest.fromJson(item.cast<String, dynamic>(), repoUrl: officialRepoUrl))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ExtensionManifest?> _loadBundledManifestById(String id) async {
    try {
      final raw = await rootBundle.loadString('assets/resources/extensions/index.json');
      final list = jsonDecode(raw) as List;
      for (final item in list) {
        if (item is Map && item['id'] == id) {
          return ExtensionManifest.fromJson(item.cast<String, dynamic>(), repoUrl: officialRepoUrl);
        }
      }
    } catch (_) {}
    return null;
  }

  ExtensionManifest _parseManifestFromDartHeader(String sourceCode, String url) {
    String? readTag(String tag) {
      final match = RegExp('^\\s*//\\s*@$tag\\s+(.+)\$', multiLine: true).firstMatch(sourceCode);
      return match?.group(1)?.trim();
    }

    final fileName = Uri.tryParse(url)?.pathSegments.lastOrNull?.replaceAll('.dart', '') ?? 'custom';
    final id = readTag('id') ?? 'PROVGUID-EXT-${fileName.toUpperCase()}';
    final name = readTag('name') ?? fileName;
    final version = readTag('version') ?? '1.0.0';
    final lang = readTag('lang') ?? 'pl';
    final author = readTag('author') ?? 'Custom';
    final iconUrl = readTag('icon') ?? '';
    final bannerUrl = readTag('banner') ?? iconUrl;
    final baseUrl = readTag('baseUrl') ?? '';
    final loginType = int.tryParse(readTag('loginType') ?? '20') ?? 20;
    final description = readTag('description') ?? 'Custom Dart register extension';

    return ExtensionManifest(
      id: id,
      name: name,
      description: description,
      version: version,
      lang: lang,
      author: author,
      iconUrl: iconUrl,
      bannerUrl: bannerUrl,
      baseUrl: baseUrl,
      sourceCodeUrl: url,
      loginType: loginType,
      repoUrl: url,
      sourceCode: sourceCode,
      credentials: const [
        ExtensionCredentialField(key: 'login', name: '/Session/Login/Username'),
        ExtensionCredentialField(key: 'pass', name: '/Session/Login/Password', obscure: true),
      ],
    );
  }

  Future<void> _saveState() async {
    try {
      final box = await Hive.openBox('extensions');
      await box.put(
        'repositories',
        jsonEncode(_repositories.map((r) => r.toJson()).toList()),
      );
      await box.put(
        'installed',
        jsonEncode(_installed.values.map((m) => m.toJson(includeSourceCode: true)).toList()),
      );
    } catch (e) {
      debugPrint('[ExtensionManager] _saveState error: $e');
    }
  }

  Future<File> _scriptFile(String id) async {
    final dir = await getApplicationSupportDirectory();
    final safeName = id.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final extDir = Directory('${dir.path}/extensions');
    if (!await extDir.exists()) {
      await extDir.create(recursive: true);
    }
    return File('${extDir.path}/$safeName.dart');
  }

  Future<void> _writeScriptToDisk(String id, String sourceCode) async {
    try {
      final file = await _scriptFile(id);
      await file.writeAsString(sourceCode);
    } catch (_) {}
  }

  Future<String?> _readScriptFromDisk(String id) async {
    try {
      final file = await _scriptFile(id);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _deleteScriptFromDisk(String id) async {
    try {
      final file = await _scriptFile(id);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
