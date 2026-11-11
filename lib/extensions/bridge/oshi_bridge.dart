import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:d4rt/d4rt.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/models/data/announcement.dart' as models;
import 'package:oshi/models/data/event.dart' as models;
import 'package:oshi/models/data/messages.dart' as models;
import 'package:oshi/models/data/teacher.dart' as models;
import 'package:oshi/models/progress.dart';
import 'package:oshi/models/provider.dart' as models;
import 'package:oshi/providers/librus/librus_data.dart';
import 'package:oshi/providers/sample/sample_data.dart';
import 'package:oshi/providers/vulcan/hebe_signer.dart';
import 'package:oshi/providers/vulcan/vulcan_data.dart';
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
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  dynamic get json {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
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
      validateStatus: (_) => true,
    ));
    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(_cookieJar));
    }
  }

  late final Dio _dio;
  final CookieJar _cookieJar = CookieJar();

  void setHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void clearCookies() {
    _cookieJar.deleteAll();
  }

  Future<OHttpResponse> get(String url, {Map<String, dynamic>? headers, Map<String, dynamic>? query}) async {
    final res = await _dio.get<String>(
      url,
      queryParameters: query,
      options: Options(
        headers: headers?.map((k, v) => MapEntry(k.toString(), v)),
        responseType: ResponseType.plain,
      ),
    );
    return _wrap(res);
  }

  Future<OHttpResponse> post(String url, {Object? body, Map<String, dynamic>? headers}) async {
    final res = await _dio.post<String>(
      url,
      data: body,
      options: Options(
        headers: headers?.map((k, v) => MapEntry(k.toString(), v)),
        responseType: ResponseType.plain,
      ),
    );
    return _wrap(res);
  }

  Future<OHttpResponse> put(String url, {Object? body, Map<String, dynamic>? headers}) async {
    final res = await _dio.put<String>(
      url,
      data: body,
      options: Options(
        headers: headers?.map((k, v) => MapEntry(k.toString(), v)),
        responseType: ResponseType.plain,
      ),
    );
    return _wrap(res);
  }

  Future<OHttpResponse> delete(String url, {Object? body, Map<String, dynamic>? headers}) async {
    final res = await _dio.delete<String>(
      url,
      data: body,
      options: Options(
        headers: headers?.map((k, v) => MapEntry(k.toString(), v)),
        responseType: ResponseType.plain,
      ),
    );
    return _wrap(res);
  }

  OHttpResponse _wrap(Response<String> res) {
    final hdrs = <String, String>{};
    res.headers.forEach((k, v) => hdrs[k] = v.join(', '));
    return OHttpResponse(
      statusCode: res.statusCode ?? 0,
      body: res.data ?? '',
      headers: hdrs,
    );
  }
}

/// High-performance protocol driver bridged to `d4rt` extensions so official and third-party
/// extensions (Librus Synergia, eduVULCAN / Hebe, Sample, or custom drivers) can execute
/// parallel multi-endpoint requests, HTML scraping, and RSA signing while keeping their
/// provider lifecycle and configuration inside the `.dart` extension script.
class OProtocolDriver {
  OProtocolDriver(this.protocol, {required this.hostContext}) {
    _delegate = switch (protocol.toLowerCase()) {
      'librus' || 'synergia' => LibrusDataReader(),
      'vulcan' || 'hebe' || 'eduvulcan' => VulcanDataReader(),
      'sample' || 'fake' => FakeDataReader(),
      _ => FakeDataReader(),
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
            ),
      },
      getters: {
        'statusCode': (visitor, target) => (target as OHttpResponse).statusCode,
        'body': (visitor, target) => (target as OHttpResponse).body,
        'headers': (visitor, target) => (target as OHttpResponse).headers,
        'json': (visitor, target) => (target as OHttpResponse).json,
      },
    );

    final oHttpClientBridge = BridgedClass(
      nativeType: OHttpClient,
      name: 'OHttpClient',
      constructors: {
        '': (visitor, positionalArgs, namedArgs) => OHttpClient(
              baseUrl: namedArgs['baseUrl'] as String?,
              defaultHeaders: (namedArgs['defaultHeaders'] as Map?)?.cast<String, String>(),
            ),
      },
      methods: {
        'setHeader': (visitor, target, positionalArgs, namedArgs) =>
            (target as OHttpClient).setHeader(positionalArgs[0] as String, positionalArgs[1] as String),
        'clearCookies': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).clearCookies(),
        'get': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).get(
              positionalArgs[0] as String,
              headers: (namedArgs['headers'] as Map?)?.cast<String, dynamic>(),
              query: (namedArgs['query'] as Map?)?.cast<String, dynamic>(),
            ),
        'post': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).post(
              positionalArgs[0] as String,
              body: namedArgs['body'],
              headers: (namedArgs['headers'] as Map?)?.cast<String, dynamic>(),
            ),
        'put': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).put(
              positionalArgs[0] as String,
              body: namedArgs['body'],
              headers: (namedArgs['headers'] as Map?)?.cast<String, dynamic>(),
            ),
        'delete': (visitor, target, positionalArgs, namedArgs) => (target as OHttpClient).delete(
              positionalArgs[0] as String,
              body: namedArgs['body'],
              headers: (namedArgs['headers'] as Map?)?.cast<String, dynamic>(),
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
          final map = jsonDecode(jsonEncode(positionalArgs[0])) as Map<String, dynamic>;
          hostContext.lastData = models.ProviderData.fromJson(map);
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

    interpreter.registertopLevelFunction(
      'generateHebeKeyPair',
      (visitor, positionalArgs, namedArgs, _) {
        final kp = HebeSigner.generateKeyPair();
        return <String, String>{
          'certificate': kp.certificate,
          'privateKey': kp.privateKey,
          'fingerprint': kp.fingerprint,
        };
      },
    );

    interpreter.registertopLevelFunction(
      'getHebeSignatureHeaders',
      (visitor, positionalArgs, namedArgs, _) {
        return HebeSigner.getSignatureHeaders(
          keyId: (namedArgs['keyId'] ?? '').toString(),
          privateKeyJson: (namedArgs['privateKeyJson'] ?? '').toString(),
          body: namedArgs['body']?.toString(),
          requestPath: (namedArgs['requestPath'] ?? '').toString(),
        );
      },
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
      'md5Hex',
      (visitor, positionalArgs, namedArgs, _) {
        final input = positionalArgs.isNotEmpty ? positionalArgs[0].toString() : '';
        return md5.convert(utf8.encode(input)).toString();
      },
    );
  }
}

