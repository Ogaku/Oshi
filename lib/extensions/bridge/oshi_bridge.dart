import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:d4rt/d4rt.dart';
import 'package:dio/dio.dart';
import 'package:oshi/extensions/bridge/rsa_signer.dart';
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/models/data/announcement.dart' as models;
import 'package:oshi/models/data/event.dart' as models;
import 'package:oshi/models/data/messages.dart' as models;
import 'package:oshi/models/data/student.dart' as models;
import 'package:oshi/models/data/teacher.dart' as models;
import 'package:oshi/models/data/timetables.dart' as models;
import 'package:oshi/models/progress.dart';
import 'package:oshi/models/provider.dart' as models;
import 'package:oshi/providers/sample/sample_data.dart';
import 'package:oshi/share/translator.dart';
import 'package:uuid/uuid.dart';

/// Metadata passed to `main(OSource source)` inside a `.dart` extension executed by `d4rt`.
class OSource {
  OSource({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.lang,
    required this.baseUrl,
    required this.iconUrl,
    this.bannerUrl,
    this.loginType = 20,
  });

  final String id;
  final String name;
  final String description;
  final String version;
  final String lang;
  final String baseUrl;
  final String iconUrl;
  final String? bannerUrl;
  final int loginType;

  factory OSource.fromManifest(ExtensionManifest manifest) => OSource(
        id: manifest.id,
        name: manifest.localizedName,
        description: manifest.localizedDescription,
        version: manifest.version,
        lang: manifest.lang,
        baseUrl: manifest.baseUrl,
        iconUrl: manifest.iconUrl,
        bannerUrl: manifest.bannerUrl,
        loginType: manifest.loginType,
      );
}

/// Base class for all Oshi `.dart` provider extensions (mirrors Mangayomi's `MProvider`).
abstract class OProvider {
  OProvider();

  String get providerName => '';
  String get providerDescription => '';
  String get providerBannerUrl => '';

  Future<Map<String, dynamic>> login(Map<String, String> credentials);
  Future<Map<String, dynamic>> refresh(String? weekStartIso);
  Future<Map<String, dynamic>> refreshMessages();
  Future<Map<String, dynamic>> sendMessage(List<Map<String, dynamic>> receivers, String topic, String content);
  Future<Map<String, dynamic>> fetchMessageContent(Map<String, dynamic> parent, bool byMe);
  Future<Map<String, dynamic>> moveMessageToTrash(Map<String, dynamic> parent, bool byMe);
  Future<Map<String, dynamic>> markEventAsViewed(Map<String, dynamic> parent);
  Future<Map<String, dynamic>> markEventAsDone(Map<String, dynamic> parent);
  Future<Map<String, dynamic>> markAnnouncementAsViewed(Map<String, dynamic> parent);
  Map<String, dynamic> getRegisterDataJson();
}

/// HTTP response exposed to `d4rt` extension scripts via `package:oshi/bridge_lib.dart`.
class OHttpResponse {
  OHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    this.url = '',
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final String url;

  String? get location {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'location') return entry.value;
    }
    return null;
  }

  dynamic get json {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}

class _StoredCookie {
  _StoredCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.path,
    required this.hostOnly,
    required this.secure,
    this.expiresAt,
  });

  final String name;
  final String value;
  final String domain;
  final String path;
  final bool hostOnly;
  final bool secure;
  final DateTime? expiresAt;

  bool isExpired(DateTime nowUtc) => expiresAt != null && !expiresAt!.isAfter(nowUtc);
}

class _CookieStore {
  final List<_StoredCookie> _cookies = [];

  static const Map<String, int> _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  void clear() => _cookies.clear();

  void saveFromHeaders(Uri requestUri, List<String> setCookieHeaders) {
    final nowUtc = DateTime.now().toUtc();
    final reqHost = requestUri.host.toLowerCase();

    for (final rawHeader in setCookieHeaders) {
      final parts = rawHeader.split(';');
      if (parts.isEmpty) continue;

      final firstPart = parts[0];
      final eqIdx = firstPart.indexOf('=');
      if (eqIdx <= 0) continue;

      final name = firstPart.substring(0, eqIdx).trim();
      final value = firstPart.substring(eqIdx + 1).trim();
      if (name.isEmpty) continue;

      var domain = reqHost;
      var hostOnly = true;
      var path = '/';
      var secure = false;
      DateTime? expiresAt;
      var hasMaxAge = false;

      for (var i = 1; i < parts.length; i++) {
        final attr = parts[i].trim();
        if (attr.isEmpty) continue;
        final attrEq = attr.indexOf('=');
        final key = (attrEq >= 0 ? attr.substring(0, attrEq) : attr).trim().toLowerCase();
        final val = attrEq >= 0 ? attr.substring(attrEq + 1).trim() : '';

        switch (key) {
          case 'domain':
            var normalized = val.toLowerCase();
            while (normalized.startsWith('.')) {
              normalized = normalized.substring(1);
            }
            if (normalized.isNotEmpty &&
                (reqHost == normalized || reqHost.endsWith('.$normalized'))) {
              domain = normalized;
              hostOnly = false;
            }
          case 'path':
            if (val.startsWith('/')) {
              path = val;
            } else {
              path = '/';
            }
          case 'secure':
            secure = true;
          case 'max-age':
            final secs = int.tryParse(val);
            if (secs != null) {
              hasMaxAge = true;
              expiresAt = secs <= 0
                  ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
                  : nowUtc.add(Duration(seconds: secs));
            }
          case 'expires':
            if (!hasMaxAge) {
              expiresAt = _parseHttpDate(val);
            }
        }
      }

      _cookies.removeWhere(
        (c) => c.name == name && c.domain == domain && c.path == path && c.hostOnly == hostOnly,
      );

      final cookie = _StoredCookie(
        name: name,
        value: value,
        domain: domain,
        path: path,
        hostOnly: hostOnly,
        secure: secure,
        expiresAt: expiresAt,
      );

      if (!cookie.isExpired(nowUtc)) {
        _cookies.add(cookie);
      }
    }
  }

  void setCookie(Uri uri, String name, String value, {String path = '/', bool hostOnly = true}) {
    final host = uri.host.toLowerCase();
    final normPath = path.startsWith('/') ? path : '/';
    _cookies.removeWhere(
      (c) => c.name == name && c.domain == host && c.path == normPath && c.hostOnly == hostOnly,
    );
    _cookies.add(_StoredCookie(
      name: name,
      value: value,
      domain: host,
      path: normPath,
      hostOnly: hostOnly,
      secure: false,
    ));
  }

  Map<String, String> cookiesFor(Uri uri) {
    final nowUtc = DateTime.now().toUtc();
    _cookies.removeWhere((c) => c.isExpired(nowUtc));

    final host = uri.host.toLowerCase();
    final reqPath = uri.path.isEmpty ? '/' : uri.path;
    final isHttps = uri.scheme.toLowerCase() == 'https';

    final matched = <_StoredCookie>[];
    for (final c in _cookies) {
      if (c.secure && !isHttps) continue;
      if (c.hostOnly) {
        if (host != c.domain) continue;
      } else {
        if (host != c.domain && !host.endsWith('.${c.domain}')) continue;
      }

      final pathMatches = c.path == '/' ||
          reqPath == c.path ||
          (reqPath.startsWith(c.path) &&
              (c.path.endsWith('/') || reqPath[c.path.length] == '/'));
      if (!pathMatches) continue;
      matched.add(c);
    }

    matched.sort((a, b) => b.path.length.compareTo(a.path.length));
    final out = <String, String>{};
    for (final c in matched) {
      out.putIfAbsent(c.name, () => c.value);
    }
    return out;
  }

  String cookieHeaderFor(Uri uri) {
    final matched = cookiesFor(uri);
    if (matched.isEmpty) return '';
    return matched.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  DateTime? _parseHttpDate(String raw) {
    final match = RegExp(
      r'^(?:[A-Za-z]+,\s*)?(\d{1,2})[\s-]+([A-Za-z]{3})[\s-]+(\d{2,4})\s+(\d{2}):(\d{2}):(\d{2})',
    ).firstMatch(raw.trim());
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final month = _months[match.group(2)!.toLowerCase()];
      var year = int.parse(match.group(3)!);
      final hour = int.parse(match.group(4)!);
      final minute = int.parse(match.group(5)!);
      final second = int.parse(match.group(6)!);
      if (month == null) return null;
      if (year < 100) year += year >= 70 ? 1900 : 2000;
      return DateTime.utc(year, month, day, hour, minute, second);
    }
    return DateTime.tryParse(raw.trim())?.toUtc();
  }
}

/// Cookie-aware HTTP client exposed to `d4rt` extension scripts via `package:oshi/bridge_lib.dart`.
class OHttpClient {
  OHttpClient({String? baseUrl, Map<String, String>? defaultHeaders}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: defaultHeaders,
      responseType: ResponseType.plain,
      followRedirects: false,
      validateStatus: (_) => true,
    ));
  }

  late final Dio _dio;
  final _CookieStore _cookieStore = _CookieStore();

  void setHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void clearCookies() {
    _cookieStore.clear();
  }

  Map<String, String> getCookies(String url) {
    return _cookieStore.cookiesFor(_resolveUri(url, null));
  }

  void setCookie(String url, String name, String value, {String path = '/', bool hostOnly = true}) {
    _cookieStore.setCookie(_resolveUri(url, null), name, value, path: path, hostOnly: hostOnly);
  }

  Future<OHttpResponse> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
    bool followRedirects = true,
  }) =>
      _request(
        'GET',
        url,
        headers: headers,
        query: query,
        followRedirects: followRedirects,
      );

  Future<OHttpResponse> post(
    String url, {
    Object? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
    bool followRedirects = true,
  }) =>
      _request(
        'POST',
        url,
        body: body,
        headers: headers,
        query: query,
        followRedirects: followRedirects,
      );

  Future<OHttpResponse> put(
    String url, {
    Object? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
    bool followRedirects = true,
  }) =>
      _request(
        'PUT',
        url,
        body: body,
        headers: headers,
        query: query,
        followRedirects: followRedirects,
      );

  Future<OHttpResponse> delete(
    String url, {
    Object? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
    bool followRedirects = true,
  }) =>
      _request(
        'DELETE',
        url,
        body: body,
        headers: headers,
        query: query,
        followRedirects: followRedirects,
      );

  Uri _resolveUri(String url, Map<String, dynamic>? query) {
    var uri = Uri.parse(url);
    if (!uri.hasScheme && _dio.options.baseUrl.isNotEmpty) {
      uri = Uri.parse(_dio.options.baseUrl).resolveUri(uri);
    }
    if (query != null && query.isNotEmpty) {
      final merged = <String, dynamic>{...uri.queryParametersAll};
      for (final entry in query.entries) {
        final key = entry.key;
        final val = entry.value;
        if (val == null) continue;
        if (val is Iterable) {
          merged[key] = val.map((e) => e.toString()).toList();
        } else {
          merged[key] = val.toString();
        }
      }
      uri = uri.replace(queryParameters: merged);
    }
    return uri;
  }

  Future<OHttpResponse> _request(
    String method,
    String url, {
    Object? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
    bool followRedirects = true,
  }) async {
    var currentMethod = method.toUpperCase();
    var currentUri = _resolveUri(url, query);
    var currentBody = body;

    final baseHeaders = <String, dynamic>{};
    if (headers != null) {
      for (final entry in headers.entries) {
        baseHeaders[entry.key.toString()] = entry.value;
      }
    }

    for (var hop = 0; hop <= 12; hop++) {
      final reqHeaders = <String, dynamic>{...baseHeaders};
      final explicitCookieKey = _findHeaderKey(reqHeaders, 'cookie');
      if (hop > 0 && explicitCookieKey != null) {
        reqHeaders.remove(explicitCookieKey);
      }

      if (hop > 0 || explicitCookieKey == null) {
        final cookieHeader = _cookieStore.cookieHeaderFor(currentUri);
        if (cookieHeader.isNotEmpty) {
          reqHeaders['Cookie'] = cookieHeader;
        }
      }

      final res = await _dio.requestUri<String>(
        currentUri,
        data: currentBody,
        options: Options(
          method: currentMethod,
          headers: reqHeaders.isEmpty ? null : reqHeaders,
          responseType: ResponseType.plain,
          followRedirects: false,
          validateStatus: (_) => true,
        ),
      );

      final setCookies = res.headers['set-cookie'];
      if (setCookies != null && setCookies.isNotEmpty) {
        _cookieStore.saveFromHeaders(currentUri, setCookies);
      }

      final status = res.statusCode ?? 0;
      final isRedirect = status == 301 || status == 302 || status == 303 || status == 307 || status == 308;
      if (!followRedirects || !isRedirect || hop == 12) {
        return _wrap(res, currentUri);
      }

      final location = res.headers.value('location');
      if (location == null || location.isEmpty) {
        return _wrap(res, currentUri);
      }

      final nextUri = currentUri.resolve(location);
      if (nextUri.host.toLowerCase() != currentUri.host.toLowerCase()) {
        final authKey = _findHeaderKey(baseHeaders, 'authorization');
        if (authKey != null) baseHeaders.remove(authKey);
      }

      if (status == 301 || status == 302 || status == 303) {
        currentMethod = 'GET';
        currentBody = null;
        final ctKey = _findHeaderKey(baseHeaders, 'content-type');
        if (ctKey != null) baseHeaders.remove(ctKey);
        final clKey = _findHeaderKey(baseHeaders, 'content-length');
        if (clKey != null) baseHeaders.remove(clKey);
      }

      currentUri = nextUri;
    }

    throw StateError('Exceeded maximum redirect count.');
  }

  String? _findHeaderKey(Map<String, dynamic> headers, String lowerName) {
    for (final key in headers.keys) {
      if (key.toLowerCase() == lowerName) return key;
    }
    return null;
  }

  OHttpResponse _wrap(Response<String> res, Uri finalUri) {
    final hdrs = <String, String>{};
    res.headers.forEach((k, v) => hdrs[k] = v.join(', '));
    return OHttpResponse(
      statusCode: res.statusCode ?? 0,
      body: res.data ?? '',
      headers: hdrs,
      url: finalUri.toString(),
    );
  }
}

/// Built-in demo protocol driver bridged to `d4rt` extensions for standalone sample data.
class OProtocolDriver {
  OProtocolDriver(this.protocol, {OExtensionHostContext? hostContext})
      : hostContext = hostContext ?? OExtensionHostContext() {
    _delegate = switch (protocol.toLowerCase()) {
      'sample' || 'fake' || 'demo' => FakeDataReader(),
      _ => throw UnsupportedError(
          'Built-in protocol driver "$protocol" is no longer bundled in Oshi. '
          'Please update the extension to a self-contained implementation.',
        ),
    };
  }

  final String protocol;
  final OExtensionHostContext hostContext;
  late final models.IProvider _delegate;

  models.ProviderData? get registerData => _delegate.registerData;

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    final creds = credentials.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    final res = await _delegate.login(credentials: creds, progress: hostContext.activeProgress);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> refresh(String? weekStartIso) async {
    final weekStart = (weekStartIso != null && weekStartIso.isNotEmpty) ? DateTime.tryParse(weekStartIso) : null;
    final res = await _delegate.refresh(weekStart: weekStart, progress: hostContext.activeProgress);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> refreshMessages() async {
    final res = await _delegate.refreshMessages(progress: hostContext.activeProgress);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> sendMessage(List<dynamic> receivers, String topic, String content) async {
    final teachers = receivers
        .whereType<Map>()
        .map((m) => models.Teacher.fromJson(m.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
    final res = await _delegate.sendMessage(receivers: teachers, topic: topic, content: content);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> fetchMessageContent(Map<String, dynamic> parent, bool byMe) async {
    final msg = models.Message.fromJson(parent);
    final res = await _delegate.fetchMessageContent(parent: msg, byMe: byMe);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
      if (res.result != null) 'result': jsonDecode(jsonEncode(res.result!.toJson())),
    };
  }

  Future<Map<String, dynamic>> moveMessageToTrash(Map<String, dynamic> parent, bool byMe) async {
    final msg = models.Message.fromJson(parent);
    final res = await _delegate.moveMessageToTrash(parent: msg, byMe: byMe);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> markEventAsViewed(Map<String, dynamic> parent) async {
    final ev = models.Event.fromJson(parent);
    final res = await _delegate.markEventAsViewed(parent: ev);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> markEventAsDone(Map<String, dynamic> parent) async {
    final ev = models.Event.fromJson(parent);
    final res = await _delegate.markEventAsDone(parent: ev);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }

  Future<Map<String, dynamic>> markAnnouncementAsViewed(Map<String, dynamic> parent) async {
    final ann = models.Announcement.fromJson(parent);
    final res = await _delegate.markAnnouncementAsViewed(parent: ann);
    hostContext.lastData = _delegate.registerData;
    return {
      'success': res.success,
      if (res.message != null) 'message': res.message.toString(),
    };
  }
}

/// Shared execution context between `DartExtensionProvider` and the `d4rt` bridge.
class OExtensionHostContext {
  IProgress<({double? progress, String? message})>? activeProgress;
  models.ProviderData? lastData;

  /// Merges serialized partial or complete `ProviderData` payloads without wiping existing slices.
  void setRegisterDataFromMap(Map raw) {
    final map = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    final existing = lastData;
    if (existing == null) {
      lastData = models.ProviderData.fromJson(map);
      return;
    }

    final studentMap = map['student'];
    final timetablesMap = map['timetables'];
    final messagesMap = map['messages'];

    lastData = models.ProviderData(
      student: studentMap is Map<String, dynamic>
          ? models.Student.fromJson(studentMap)
          : existing.student,
      timetables: timetablesMap is Map<String, dynamic>
          ? models.Timetables.fromJson(timetablesMap)
          : existing.timetables,
      messages: messagesMap is Map<String, dynamic>
          ? models.Messages.fromJson(messagesMap)
          : existing.messages,
    );
  }
}

/// Registers `package:oshi/bridge_lib.dart` into a `D4rt` interpreter instance.
class OshiBridge {
  static const String libraryUri = 'package:oshi/bridge_lib.dart';

  static void register(D4rt interpreter, OExtensionHostContext hostContext) {
    final oSourceBridge = BridgedClass(
      nativeType: OSource,
      name: 'OSource',
      constructors: {
        '': (visitor, positionalArgs, namedArgs) => OSource(
              id: (namedArgs['id'] ?? '').toString(),
              name: (namedArgs['name'] ?? '').toString(),
              description: (namedArgs['description'] ?? '').toString(),
              version: (namedArgs['version'] ?? '1.0.0').toString(),
              lang: (namedArgs['lang'] ?? 'pl').toString(),
              baseUrl: (namedArgs['baseUrl'] ?? '').toString(),
              iconUrl: (namedArgs['iconUrl'] ?? '').toString(),
              bannerUrl: namedArgs['bannerUrl']?.toString(),
              loginType: namedArgs['loginType'] is int ? namedArgs['loginType'] as int : 20,
            ),
      },
      getters: {
        'id': (visitor, target) => (target as OSource).id,
        'name': (visitor, target) => (target as OSource).name,
        'description': (visitor, target) => (target as OSource).description,
        'version': (visitor, target) => (target as OSource).version,
        'lang': (visitor, target) => (target as OSource).lang,
        'baseUrl': (visitor, target) => (target as OSource).baseUrl,
        'iconUrl': (visitor, target) => (target as OSource).iconUrl,
        'bannerUrl': (visitor, target) => (target as OSource).bannerUrl,
        'loginType': (visitor, target) => (target as OSource).loginType,
      },
    );

    final oProviderBridge = BridgedClass(
      nativeType: OProvider,
      name: 'OProvider',
      constructors: {
        '': (visitor, positionalArgs, namedArgs) => OProvider,
      },
      getters: {
        'providerName': (visitor, target) => (target as OProvider).providerName,
        'providerDescription': (visitor, target) => (target as OProvider).providerDescription,
        'providerBannerUrl': (visitor, target) => (target as OProvider).providerBannerUrl,
      },
      methods: {
        'login': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProvider).login((positionalArgs[0] as Map).cast<String, String>()),
        'refresh': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProvider).refresh(positionalArgs.isNotEmpty ? positionalArgs[0] as String? : null),
        'refreshMessages': (visitor, target, positionalArgs, namedArgs) => (target as OProvider).refreshMessages(),
        'sendMessage': (visitor, target, positionalArgs, namedArgs) => (target as OProvider).sendMessage(
              (positionalArgs[0] as List).map((e) => (e as Map).cast<String, dynamic>()).toList(),
              positionalArgs[1] as String,
              positionalArgs[2] as String,
            ),
        'fetchMessageContent': (visitor, target, positionalArgs, namedArgs) => (target as OProvider).fetchMessageContent(
              (positionalArgs[0] as Map).cast<String, dynamic>(),
              positionalArgs[1] as bool,
            ),
        'moveMessageToTrash': (visitor, target, positionalArgs, namedArgs) => (target as OProvider).moveMessageToTrash(
              (positionalArgs[0] as Map).cast<String, dynamic>(),
              positionalArgs[1] as bool,
            ),
        'markEventAsViewed': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProvider).markEventAsViewed((positionalArgs[0] as Map).cast<String, dynamic>()),
        'markEventAsDone': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProvider).markEventAsDone((positionalArgs[0] as Map).cast<String, dynamic>()),
        'markAnnouncementAsViewed': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProvider).markAnnouncementAsViewed((positionalArgs[0] as Map).cast<String, dynamic>()),
        'getRegisterDataJson': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProvider).getRegisterDataJson(),
      },
    );

    final oHttpResponseBridge = BridgedClass(
      nativeType: OHttpResponse,
      name: 'OHttpResponse',
      constructors: {
        '': (visitor, positionalArgs, namedArgs) => OHttpResponse(
              statusCode: namedArgs['statusCode'] as int? ?? 200,
              body: namedArgs['body'] as String? ?? '',
              headers: (namedArgs['headers'] as Map?)?.cast<String, String>() ?? const {},
              url: namedArgs['url']?.toString() ?? '',
            ),
      },
      getters: {
        'statusCode': (visitor, target) => (target as OHttpResponse).statusCode,
        'body': (visitor, target) => (target as OHttpResponse).body,
        'headers': (visitor, target) => (target as OHttpResponse).headers,
        'json': (visitor, target) => (target as OHttpResponse).json,
        'url': (visitor, target) => (target as OHttpResponse).url,
        'location': (visitor, target) => (target as OHttpResponse).location,
      },
    );

    final oHttpClientBridge = BridgedClass(
      nativeType: OHttpClient,
      name: 'OHttpClient',
      constructors: {
        '': (visitor, positionalArgs, namedArgs) => OHttpClient(
              baseUrl: namedArgs['baseUrl'] as String?,
              defaultHeaders: (namedArgs['defaultHeaders'] as Map?)?.map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ),
            ),
      },
      methods: {
        'setHeader': (visitor, target, positionalArgs, namedArgs) =>
            (target as OHttpClient).setHeader(positionalArgs[0].toString(), positionalArgs[1].toString()),
        'clearCookies': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).clearCookies(),
        'getCookies': (visitor, target, positionalArgs, namedArgs) =>
            (target as OHttpClient).getCookies(positionalArgs[0].toString()),
        'setCookie': (visitor, target, positionalArgs, namedArgs) {
          (target as OHttpClient).setCookie(
            positionalArgs[0].toString(),
            positionalArgs[1].toString(),
            positionalArgs[2].toString(),
            path: namedArgs['path']?.toString() ?? '/',
            hostOnly: namedArgs['hostOnly'] != false,
          );
          return null;
        },
        'get': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).get(
              positionalArgs[0].toString(),
              headers: (namedArgs['headers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              query: (namedArgs['query'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              followRedirects: namedArgs['followRedirects'] != false,
            ),
        'post': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).post(
              positionalArgs[0].toString(),
              body: namedArgs['body'],
              headers: (namedArgs['headers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              query: (namedArgs['query'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              followRedirects: namedArgs['followRedirects'] != false,
            ),
        'put': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).put(
              positionalArgs[0].toString(),
              body: namedArgs['body'],
              headers: (namedArgs['headers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              query: (namedArgs['query'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              followRedirects: namedArgs['followRedirects'] != false,
            ),
        'delete': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).delete(
              positionalArgs[0].toString(),
              body: namedArgs['body'],
              headers: (namedArgs['headers'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              query: (namedArgs['query'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)),
              followRedirects: namedArgs['followRedirects'] != false,
            ),
      },
    );

    final oProtocolDriverBridge = BridgedClass(
      nativeType: OProtocolDriver,
      name: 'OProtocolDriver',
      constructors: {
        '': (visitor, positionalArgs, namedArgs) => OProtocolDriver(
              positionalArgs.isNotEmpty ? positionalArgs[0].toString() : 'sample',
              hostContext: hostContext,
            ),
      },
      methods: {
        'login': (visitor, target, positionalArgs, namedArgs) => (target as OProtocolDriver).login(
              positionalArgs.isNotEmpty && positionalArgs[0] is Map
                  ? (positionalArgs[0] as Map).map((k, v) => MapEntry(k.toString(), v))
                  : <String, dynamic>{},
            ),
        'refresh': (visitor, target, positionalArgs, namedArgs) => (target as OProtocolDriver).refresh(
              positionalArgs.isNotEmpty ? positionalArgs[0]?.toString() : null,
            ),
        'refreshMessages': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProtocolDriver).refreshMessages(),
        'sendMessage': (visitor, target, positionalArgs, namedArgs) => (target as OProtocolDriver).sendMessage(
              positionalArgs[0] as List,
              positionalArgs[1].toString(),
              positionalArgs[2].toString(),
            ),
        'fetchMessageContent': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProtocolDriver).fetchMessageContent(
              (positionalArgs[0] as Map).map((k, v) => MapEntry(k.toString(), v)),
              positionalArgs[1] == true,
            ),
        'moveMessageToTrash': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProtocolDriver).moveMessageToTrash(
              (positionalArgs[0] as Map).map((k, v) => MapEntry(k.toString(), v)),
              positionalArgs[1] == true,
            ),
        'markEventAsViewed': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProtocolDriver).markEventAsViewed(
              (positionalArgs[0] as Map).map((k, v) => MapEntry(k.toString(), v)),
            ),
        'markEventAsDone': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProtocolDriver).markEventAsDone(
              (positionalArgs[0] as Map).map((k, v) => MapEntry(k.toString(), v)),
            ),
        'markAnnouncementAsViewed': (visitor, target, positionalArgs, namedArgs) =>
            (target as OProtocolDriver).markAnnouncementAsViewed(
              (positionalArgs[0] as Map).map((k, v) => MapEntry(k.toString(), v)),
            ),
      },
    );

    interpreter.registerBridgedClass(oSourceBridge, libraryUri);
    interpreter.registerBridgedClass(oProviderBridge, libraryUri);
    interpreter.registerBridgedClass(oHttpResponseBridge, libraryUri);
    interpreter.registerBridgedClass(oHttpClientBridge, libraryUri);
    interpreter.registerBridgedClass(oProtocolDriverBridge, libraryUri);

    // Top-level helper functions available in `package:oshi/bridge_lib.dart`
    interpreter.registertopLevelFunction(
      'reportProgress',
      (visitor, positionalArgs, namedArgs, _) {
        final p = positionalArgs.isNotEmpty && positionalArgs[0] is num ? (positionalArgs[0] as num).toDouble() : null;
        final m = positionalArgs.length > 1 ? positionalArgs[1]?.toString() : null;
        hostContext.activeProgress?.report((progress: p, message: m));
        return null;
      },
    );

    interpreter.registertopLevelFunction(
      'setRegisterDataJson',
      (visitor, positionalArgs, namedArgs, _) {
        if (positionalArgs.isNotEmpty && positionalArgs[0] is Map) {
          hostContext.setRegisterDataFromMap(positionalArgs[0] as Map);
        }
        return null;
      },
    );

    interpreter.registertopLevelFunction(
      'localized',
      (visitor, positionalArgs, namedArgs, _) {
        final key = positionalArgs.isNotEmpty ? positionalArgs[0].toString() : '';
        return key.localized;
      },
    );

    Map<String, String> buildRsaKeyPair() {
      final kp = RsaHttpSigner.generateKeyPair();
      return <String, String>{
        'certificate': kp.certificate,
        'privateKey': kp.privateKey,
        'fingerprint': kp.fingerprint,
      };
    }

    Map<String, String> buildRsaSignatureHeaders(Map<String, Object?> namedArgs) {
      return RsaHttpSigner.getSignatureHeaders(
        keyId: (namedArgs['keyId'] ?? '').toString(),
        privateKeyJson: (namedArgs['privateKeyJson'] ?? '').toString(),
        body: namedArgs['body']?.toString(),
        requestPath: (namedArgs['requestPath'] ?? '').toString(),
        canonicalPattern: namedArgs['canonicalPattern']?.toString(),
      );
    }

    interpreter.registertopLevelFunction(
      'generateRsaKeyPair',
      (visitor, positionalArgs, namedArgs, _) => buildRsaKeyPair(),
    );

    interpreter.registertopLevelFunction(
      'getRsaSignatureHeaders',
      (visitor, positionalArgs, namedArgs, _) => buildRsaSignatureHeaders(namedArgs),
    );

    interpreter.registertopLevelFunction(
      'generateHebeKeyPair',
      (visitor, positionalArgs, namedArgs, _) => buildRsaKeyPair(),
    );

    interpreter.registertopLevelFunction(
      'getHebeSignatureHeaders',
      (visitor, positionalArgs, namedArgs, _) => buildRsaSignatureHeaders(namedArgs),
    );

    interpreter.registertopLevelFunction(
      'uuidV4',
      (visitor, positionalArgs, namedArgs, _) => const Uuid().v4(),
    );

    interpreter.registertopLevelFunction(
      'sha256Hex',
      (visitor, positionalArgs, namedArgs, _) {
        final input = positionalArgs.isNotEmpty ? positionalArgs[0].toString() : '';
        return sha256.convert(utf8.encode(input)).toString();
      },
    );

    interpreter.registertopLevelFunction(
      'sha256Bytes',
      (visitor, positionalArgs, namedArgs, _) {
        final input = positionalArgs.isNotEmpty ? positionalArgs[0].toString() : '';
        return RsaHttpSigner.sha256DigestBytes(input);
      },
    );

    interpreter.registertopLevelFunction(
      'md5Hex',
      (visitor, positionalArgs, namedArgs, _) {
        final input = positionalArgs.isNotEmpty ? positionalArgs[0].toString() : '';
        return md5.convert(utf8.encode(input)).toString();
      },
    );
  }
}
