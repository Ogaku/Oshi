// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:intl/intl.dart';
import 'package:oshi/models/data/announcement.dart' as models;
import 'package:oshi/models/data/attendances.dart' as models;
import 'package:oshi/models/data/class.dart' as models;
import 'package:oshi/models/data/classroom.dart' as models;
import 'package:oshi/models/data/event.dart' as models;
import 'package:oshi/models/data/grade.dart' as models;
import 'package:oshi/models/data/lesson.dart' as models;
import 'package:oshi/models/data/messages.dart' as models;
import 'package:oshi/models/data/student.dart' as models;
import 'package:oshi/models/data/teacher.dart' as models;
import 'package:oshi/models/data/timetables.dart' as models;
import 'package:oshi/models/data/unit.dart' as models;
import 'package:oshi/models/progress.dart';
import 'package:oshi/models/provider.dart' as models;
import 'package:oshi/providers/sample/sample_data.dart';
import 'package:oshi/providers/vulcan/hebe_signer.dart';
import 'package:oshi/share/translator.dart';
import 'package:uuid/uuid.dart';

class VulcanDataReader implements models.IProvider {
  static const String _hebeceAppName = 'DzienniczekPlus 3.0';
  static const String _hebeceAppVersion = '26.04.01 (G)';
  static const String _hebeceVersionCode = '946';
  static const String _hebeAppName = 'DzienniczekPlus 2.0';
  static const String _hebeAppVersion = '26.04.00 (G)';
  static const String _hebeVersionCode = '941';
  static const String _userAgent = 'Dart/3.3 (dart:io)';
  static const String _deviceOs = 'Android';
  static const String _deviceModel = 'Oshi Mobile';
  static const String _defaultHebeBaseUrl = 'https://lekcjaplus.vulcan.net.pl';

  static const Map<String, String> _tokenPrefixes = {
    '3S1': 'https://lekcjaplus.vulcan.net.pl',
    'TA1': 'https://uonetplus-komunikacja.umt.tarnow.pl',
    'OP1': 'https://uonetplus-komunikacja.eszkola.opolskie.pl',
    'RZ1': 'https://uonetplus-komunikacja.resman.pl',
    'GD1': 'https://uonetplus-komunikacja.edu.gdansk.pl',
    'KA1': 'https://uonetplus-komunikacja.mcuw.katowice.eu',
    'KA2': 'https://uonetplus-komunikacja-test.mcuw.katowice.eu',
    'LU1': 'https://uonetplus-komunikacja.edu.lublin.eu',
    'LU2': 'https://test-uonetplus-komunikacja.edu.lublin.eu',
    'KO1': 'https://uonetplus-komunikacja.eduportal.koszalin.pl',
    'FK1': 'http://api.fakelog.tk',
  };

  models.ProviderData dataChunk = models.ProviderData();
  FakeDataReader? _fakeReader;

  HebeKeyPair? _keyPair;
  String _deviceId = const Uuid().v4();
  String? _restUrl; // e.g. https://lekcjaplus.vulcan.net.pl/{tenant}/{unitSymbol}/api
  Map<String, dynamic>? _activeStudentRaw;
  bool _isHebeCe = true;
  String _proxyUrl = '';
  String? _savedUsername;
  String? _savedPassword;

  String get _topLevelPartition {
    if (_activeStudentRaw != null) {
      final top = _activeStudentRaw!['TopLevelPartition']?.toString();
      if (top != null && top.isNotEmpty) return top;
      final group = _activeStudentRaw!['Links']?['Group']?.toString();
      if (group != null && group.isNotEmpty) return group;
      final part = _activeStudentRaw!['Partition']?.toString();
      if (part != null && part.isNotEmpty) {
        return part.split('-').first;
      }
    }
    return '';
  }
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  @override
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  @override
  models.ProviderData? get registerData => _fakeReader?.registerData ?? dataChunk;

  @override
  String get providerName => 'eduVULCAN / UONET+';

  @override
  String get providerDescription => '/Providers/Vulcan/Description'.localized;

  @override
  Uri? get providerBannerUri => Uri.parse('https://eduvulcan.pl/Content/images/favicon/apple-touch-icon.png');

  @override
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig => kIsWeb
      ? {
          'login': (name: '/Session/Login/Username'.localized, obscure: false, helper: null),
          'pass': (name: '/Session/Login/Password'.localized, obscure: true, helper: null),
          'proxy': (
            name: '/Session/Login/ProxyUrl'.localized,
            obscure: false,
            helper: (
              text: '/Session/Login/ProxyHelper'.localized,
              link: Uri.parse('https://github.com/Ogaku/Oshi/wiki/Web-app')
            )
          )
        }
      : {
          'login': (name: '/Session/Login/Username'.localized, obscure: false, helper: null),
          'pass': (name: '/Session/Login/Password'.localized, obscure: true, helper: null),
        };

  @override
  Future<({bool success, Exception? message})> login({
    Map<String, String>? credentials,
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    try {
      progress?.report((progress: 0.1, message: 'D870CFEB-F16B-4091-9084-9620E5BACE22'.localized));

      final username = (credentials?['login'] ?? credentials?['username'] ?? '').trim();
      final password = credentials?['pass'] ?? credentials?['password'] ?? '';
      final proxy = credentials?['proxy']?.trim() ?? '';

      if ((username.toLowerCase() == 'test' && password == 'test') ||
          (username.toLowerCase() == 'demo' && password == 'demo')) {
        _fakeReader = FakeDataReader();
        dataChunk = _fakeReader!.registerData!;
        return (success: true, message: null);
      }
      _fakeReader = null;

      var resolvedProxy = proxy;
      if (resolvedProxy.isEmpty ||
          resolvedProxy.toLowerCase().contains('librus.pl') ||
          resolvedProxy.toLowerCase().contains('eduvulcan.pl') ||
          resolvedProxy.toLowerCase().contains('vulcan.net.pl')) {
        resolvedProxy = 'http://127.0.0.1:5000';
      }
      if (kIsWeb && Uri.tryParse(resolvedProxy) == null) {
        return (success: false, message: Exception('1DBA54DA-C4D2-4D21-B072-89AAFCC4758D'.localized));
      }
      _proxyUrl = resolvedProxy;
      _savedUsername = username;
      _savedPassword = password;

      if (username.isEmpty || (password.isEmpty && !username.contains('Tokens'))) {
        return (success: false, message: Exception('E15B042C-B7C1-43AB-9557-EA1B1F08CE9C'.localized));
      }

      _keyPair = HebeSigner.generateKeyPair();
      _deviceId = const Uuid().v4();

      progress?.report((progress: 0.25, message: '440FA18A-AD7D-47B4-B4FF-C2FE934479DA'.localized));

      // Case 1: User provided raw /api/ap JSON or HTML
      if (username.contains('Tokens') || username.contains('id="ap"') || username.contains("id='ap'")) {
        _isHebeCe = true;
        final tokens = await _extractTokensFromAp(username);
        await _registerWithJwtTokens(tokens, progress: progress);
        return (success: true, message: null);
      }

      // Case 2: Classic 3S mobile token registration (e.g. login = "3S1..." or "3S1...:symbol", pass = PIN or "symbol:PIN")
      final upperLogin = username.toUpperCase();
      if (_tokenPrefixes.keys.any((prefix) => upperLogin.startsWith(prefix)) && !username.contains('@')) {
        _isHebeCe = false;
        await _registerWithMobileToken(username, password, progress: progress);
        return (success: true, message: null);
      }

      // Case 3: Standard eduVULCAN (eduvulcan.pl) Prometheus web login -> /api/ap -> register/jwt
      _isHebeCe = true;
      progress?.report((progress: 0.35, message: '395B01AF-19EE-43BE-880D-1EAE925B33C2'.localized));
      final tokens = await _loginEduVulcanPrometheus(username, password, progress: progress);
      await _registerWithJwtTokens(tokens, progress: progress);

      return (success: true, message: null);
    } on Exception catch (ex, st) {
      debugPrint('[vulcan] FAILED: $ex\n$st');
      return (success: false, message: ex);
    } catch (ex, st) {
      debugPrint('[vulcan] FAILED(error): $ex\n$st');
      return (success: false, message: Exception(ex.toString()));
    }
  }

  Future<List<String>> _loginEduVulcanPrometheus(
    String login,
    String password, {
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    final cookieJar = CookieJar();
    final webCookies = <String, String>{};
    final webDio = Dio(BaseOptions(
      followRedirects: false,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
      },
    ));
    if (!kIsWeb) {
      webDio.interceptors.add(CookieManager(cookieJar));
    }

    // Fast path when using local Dairi proxy on Web: perform Prometheus login + PoW solve in native Python
    if (kIsWeb && _proxyUrl.isNotEmpty) {
      try {
        final fastRes = await webDio.post(
          _proxyUrl,
          data: jsonEncode({
            'action': 'eduvulcan_login',
            'login': login,
            'password': password,
          }),
        );
        if (fastRes.statusCode == 401 && fastRes.data is Map) {
          final errMsg = fastRes.data['error'] ?? fastRes.data['data']?['error'] ?? 'NieprawidÅ‚owy login lub hasÅ‚o eduVULCAN.';
          throw Exception(errMsg.toString());
        }
        if (fastRes.statusCode == 200 && fastRes.data is Map) {
          final inner = fastRes.data['data'];
          final text = inner is Map ? (inner['text'] ?? inner) : inner;
          if (text != null) {
            return await _extractTokensFromAp(text);
          }
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 && e.response?.data is Map) {
          final errMsg = e.response?.data['error'] ??
              e.response?.data['data']?['error'] ??
              'NieprawidÅ‚owy login lub hasÅ‚o eduVULCAN.';
          throw Exception(errMsg.toString());
        }
      }
    }

    const loginUrl = 'https://eduvulcan.pl/logowanie?ReturnUrl=%2fapi%2fap';

    // 1. Fetch /logowanie page and CSRF token first so session cookies are established
    final loginRes = await _webRequest(
      webDio,
      loginUrl,
      method: 'GET',
      cookies: webCookies,
    );
    final loginHtml = loginRes.toString();
    final csrfMatch = RegExp(r'name="__RequestVerificationToken"[^>]*value="([^"]+)"').firstMatch(loginHtml) ??
        RegExp(r'value="([^"]+)"[^>]*name="__RequestVerificationToken"').firstMatch(loginHtml);
    if (csrfMatch == null) {
      throw Exception('Failed to extract CSRF token from eduvulcan.pl/logowanie');
    }
    final csrfToken = csrfMatch.group(1)!;

    // 2. Check if PoW captcha is required (passes alias + __RequestVerificationToken with session cookies)
    var showCaptcha = true;
    try {
      final infoRes = await _webRequest(
        webDio,
        'https://eduvulcan.pl/Account/QueryUserInfo',
        method: 'POST',
        formData: {
          'alias': login,
          '__RequestVerificationToken': csrfToken,
        },
        cookies: webCookies,
      );
      final decoded = infoRes is Map ? infoRes : jsonDecode(infoRes.toString());
      if (decoded is Map && decoded['data'] is Map) {
        showCaptcha = decoded['data']['ShowCaptcha'] == true ||
            decoded['data']['ShowCaptcha']?.toString().toLowerCase() == 'true';
      }
    } catch (_) {
      showCaptcha = true;
    }

    var captchaResponse = '';
    if (showCaptcha) {
      final challengeMatch = RegExp(r'data-challenge="([^"]+)"').firstMatch(loginHtml);
      final difficultyMatch = RegExp(r'data-difficulty="(\d+)"').firstMatch(loginHtml);
      final roundsMatch = RegExp(r'data-rounds="(\d+)"').firstMatch(loginHtml);
      if (challengeMatch != null && difficultyMatch != null && roundsMatch != null) {
        captchaResponse = await VulcanPowSolver.solveAsync(
          challenge: challengeMatch.group(1)!,
          difficulty: int.parse(difficultyMatch.group(1)!),
          rounds: int.parse(roundsMatch.group(1)!),
        );
      }
    }

    // 3. Submit credentials to /logowanie
    final postRes = await _webRequest(
      webDio,
      loginUrl,
      method: 'POST',
      formData: {
        'Alias': login,
        'UserName': login,
        'Password': password,
        'captcha-response': captchaResponse,
        '__RequestVerificationToken': csrfToken,
      },
      cookies: webCookies,
    );

    final bodyText = postRes.toString();
    if (bodyText.contains('id="ap"') || bodyText.contains("id='ap'") || bodyText.contains('"Tokens"')) {
      return _extractTokensFromAp(postRes, webDio: webDio, webCookies: webCookies, csrfToken: csrfToken);
    }
    if (bodyText.toLowerCase().contains('robot') || bodyText.toLowerCase().contains('robak')) {
      throw Exception('eduVULCAN anti-bot verification failed');
    }
    if (bodyText.contains('id="form1"')) {
      final errMatch =
          RegExp(r'<div[^>]*class="[^"]*message-error[^"]*"[^>]*>([\s\S]*?)</div>').allMatches(bodyText);
      for (final m in errMatch) {
        final cleaned = m.group(1)!.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (cleaned.isNotEmpty) {
          throw Exception(cleaned);
        }
      }
      throw Exception('NieprawidÅ‚owy login lub hasÅ‚o eduVULCAN.');
    }

    // 4. Fetch /api/ap
    final apRes = await _webRequest(
      webDio,
      'https://eduvulcan.pl/api/ap',
      method: 'GET',
      cookies: webCookies,
    );
    return _extractTokensFromAp(apRes, webDio: webDio, webCookies: webCookies, csrfToken: csrfToken);
  }

  Future<List<String>> _extractTokensFromAp(
    dynamic rawInput, {
    Dio? webDio,
    Map<String, String>? webCookies,
    String? csrfToken,
  }) async {
    if (rawInput is Map) {
      if (rawInput['Tokens'] is List) {
        final list = (rawInput['Tokens'] as List).map((e) => e.toString()).toList();
        if (list.isNotEmpty) return list;
      }
      if (rawInput['tokens'] is List) {
        final list = (rawInput['tokens'] as List).map((e) => e.toString()).toList();
        if (list.isNotEmpty) return list;
      }
      if (rawInput['text'] is String) {
        return _extractTokensFromAp(rawInput['text'] as String,
            webDio: webDio, webCookies: webCookies, csrfToken: csrfToken);
      }
    }
    final trimmed = rawInput.toString().trim();
    String jsonStr = trimmed;
    final match = RegExp(r'''id=['"]ap['"][^>]*value=(['"])([\s\S]*?)\1''').firstMatch(trimmed) ??
        RegExp(r'''value=(['"])([\s\S]*?)\1[^>]*id=['"]ap['"]''').firstMatch(trimmed);
    if (match != null) {
      jsonStr = match
          .group(2)!
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&amp;', '&');
    }
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (decoded['Success'] == false || decoded['success'] == false) {
      throw Exception('eduVULCAN /api/ap error: ${decoded['ErrorMessage'] ?? decoded['errorMessage'] ?? 'Unknown error'}');
    }

    var tokens = ((decoded['Tokens'] ?? decoded['tokens']) as List?)?.map((e) => e.toString()).toList() ?? [];
    if (tokens.isEmpty &&
        webDio != null &&
        (decoded['IsConsentAccepted'] == false || decoded['isConsentAccepted'] == false)) {
      try {
        await _webRequest(
          webDio,
          'https://eduvulcan.pl/konto/zgody',
          method: 'POST',
          formData: {
            'Consent[0].Key': '4',
            'Consent[0].Value': 'true',
            if (csrfToken != null) '__RequestVerificationToken': csrfToken,
          },
          cookies: webCookies,
        );
        final reAp = await _webRequest(webDio, 'https://eduvulcan.pl/api/ap', method: 'GET', cookies: webCookies);
        return await _extractTokensFromAp(reAp);
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }
    }

    if (tokens.isEmpty) {
      throw Exception('No student tokens found in eduVULCAN account');
    }
    return tokens;
  }

  String _decodeJwtTenant(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) throw Exception('Invalid JWT format');
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
    final tenant = (payload['tenant'] ?? payload['Tenant'])?.toString();
    if (tenant == null || tenant.isEmpty) {
      throw Exception('JWT token missing tenant claim');
    }
    return tenant;
  }

  Future<void> _registerWithJwtTokens(
    List<String> tokens, {
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    final tenants = tokens.map(_decodeJwtTenant).toSet().toList();
    Map<String, dynamic>? selectedStudent;
    String? selectedBaseRestUrl;

    for (final tenant in tenants) {
      final host = tenant.toLowerCase() == 'lublin'
          ? 'https://uonetplus-komunikacja.edu.lublin.eu'
          : _defaultHebeBaseUrl;
      final tenantApiUrl = '$host/$tenant/api';

      try {
        await _hebeRequest(
          method: 'POST',
          restUrl: tenantApiUrl,
          endpoint: 'mobile/register/jwt',
          payload: {
            'OS': _deviceOs,
            'Certificate': _keyPair!.certificate,
            'CertificateType': 'RSA_PEM',
            'DeviceModel': _deviceModel,
            'SelfIdentifier': _deviceId,
            'CertificateThumbprint': _keyPair!.fingerprint,
            'Tokens': tokens,
          },
        );
      } catch (ex) {
        if (!ex.toString().contains('205')) {
          rethrow;
        }
        debugPrint('[vulcan] Certificate already registered (code 205), continuing to register/hebe');
      }

      final pupils = await _hebeRequest(
        method: 'GET',
        restUrl: tenantApiUrl,
        endpoint: 'mobile/register/hebe',
        query: {'mode': '2'},
      );

      if (pupils is List && pupils.isNotEmpty) {
        selectedStudent = Map<String, dynamic>.from(pupils.first as Map);
        final unitRestUrl = selectedStudent['Unit']?['RestURL']?.toString() ?? '';
        final unitSymbol = selectedStudent['Unit']?['Symbol']?.toString() ?? '';
        if (unitRestUrl.isNotEmpty) {
          final cleaned = unitRestUrl.endsWith('/') ? unitRestUrl.substring(0, unitRestUrl.length - 1) : unitRestUrl;
          selectedBaseRestUrl = cleaned.endsWith('/api') ? cleaned : '$cleaned/api';
        } else {
          selectedBaseRestUrl = unitSymbol.isNotEmpty ? '$host/$tenant/$unitSymbol/api' : tenantApiUrl;
        }
        break;
      }
    }

    if (selectedStudent == null || selectedBaseRestUrl == null) {
      throw Exception('No active student profile returned by eduVULCAN');
    }

    _activeStudentRaw = selectedStudent;
    _restUrl = selectedBaseRestUrl;
  }

  Future<void> _registerWithMobileToken(
    String loginInput,
    String passwordInput, {
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    // Supports login="TOKEN:SYMBOL", pass="PIN" OR login="TOKEN", pass="SYMBOL:PIN"
    String token = loginInput.trim().toUpperCase();
    String symbol = 'default';
    String pin = passwordInput.trim();

    if (loginInput.contains(':')) {
      final parts = loginInput.split(':');
      token = parts[0].trim().toUpperCase();
      symbol = parts[1].trim().toLowerCase();
    } else if (passwordInput.contains(':')) {
      final parts = passwordInput.split(':');
      symbol = parts[0].trim().toLowerCase();
      pin = parts[1].trim();
    }

    final prefix = token.length >= 3 ? token.substring(0, 3) : '';
    final host = _tokenPrefixes[prefix] ?? _defaultHebeBaseUrl;
    final tenantApiUrl = '$host/$symbol/api';

    try {
      await _hebeRequest(
        method: 'POST',
        restUrl: tenantApiUrl,
        endpoint: 'mobile/register/token',
        payload: {
          'OS': _deviceOs,
          'Certificate': _keyPair!.certificate,
          'CertificateType': 'RSA_PEM',
          'DeviceModel': _deviceModel,
          'SelfIdentifier': _deviceId,
          'CertificateThumbprint': _keyPair!.fingerprint,
          'SecurityToken': token,
          'PIN': pin,
        },
      );
    } catch (ex) {
      if (!ex.toString().contains('205')) {
        rethrow;
      }
      debugPrint('[vulcan] Certificate already registered (code 205), continuing to register/hebe');
    }

    final pupils = await _hebeRequest(
      method: 'GET',
      restUrl: tenantApiUrl,
      endpoint: 'mobile/register/hebe',
      query: {'mode': '2'},
    );

    if (pupils is! List || pupils.isEmpty) {
      throw Exception('No student profile returned after token registration');
    }

    _activeStudentRaw = Map<String, dynamic>.from(pupils.first as Map);
    final unitRestUrl = _activeStudentRaw!['Unit']?['RestURL']?.toString() ?? '';
    final unitSymbol = _activeStudentRaw!['Unit']?['Symbol']?.toString() ?? '';
    if (unitRestUrl.isNotEmpty) {
      final cleaned = unitRestUrl.endsWith('/') ? unitRestUrl.substring(0, unitRestUrl.length - 1) : unitRestUrl;
      _restUrl = cleaned.endsWith('/api') ? cleaned : '$cleaned/api';
    } else {
      _restUrl = unitSymbol.isNotEmpty ? '$host/$symbol/$unitSymbol/api' : tenantApiUrl;
    }
  }

  Future<dynamic> _webRequest(
    Dio dio,
    String url, {
    required String method,
    Map<String, String>? formData,
    Map<String, String>? cookies,
  }) async {
    if (kIsWeb && _proxyUrl.isNotEmpty) {
      final res = await dio.post(
        _proxyUrl,
        data: jsonEncode({
          'uri': url,
          'method': method,
          'headers': {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
            if (formData != null) 'Content-Type': 'application/x-www-form-urlencoded',
          },
          if (cookies != null) 'cookies': cookies,
          'data': formData != null ? Uri(queryParameters: formData).query : null,
        }),
      );
      if (res.data is Map) {
        if (cookies != null && res.data['cookies'] is Map) {
          cookies.addAll((res.data['cookies'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())));
        }
        final inner = res.data['data'];
        if (inner is Map && inner.length == 1 && inner['text'] is String) {
          return inner['text'] as String;
        }
        return inner ?? res.data;
      }
      return res.data;
    }
    Response<dynamic> res;
    if (method == 'POST') {
      res = await dio.post(
        url,
        data: formData != null ? Uri(queryParameters: formData).query : null,
        options: Options(contentType: Headers.formUrlEncodedContentType, followRedirects: false),
      );
    } else {
      res = await dio.get(url, options: Options(followRedirects: false));
    }
    var nextLoc = res.headers['location']?.firstOrNull;
    var currentBase = url;
    var hops = 0;
    while (nextLoc != null && hops < 6) {
      final resolvedUrl = Uri.parse(currentBase).resolve(nextLoc).toString();
      res = await dio.get(resolvedUrl, options: Options(followRedirects: false));
      currentBase = resolvedUrl;
      nextLoc = res.headers['location']?.firstOrNull;
      hops++;
    }
    return res.data;
  }

  Future<dynamic> _hebeRequest({
    required String method,
    required String restUrl,
    required String endpoint,
    Map<String, String>? query,
    Object? payload,
    int? pupilId,
  }) async {
    if (_keyPair == null) {
      throw Exception('VULCAN session is not initialized');
    }

    var fullUrl = '$restUrl/$endpoint';
    if (query != null && query.isNotEmpty) {
      final q = query.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      fullUrl = '$fullUrl?$q';
    }

    final now = DateTime.now().toUtc();
    String? bodyJson;
    if (payload != null) {
      final envelopeBody = {
        'AppName': _isHebeCe ? _hebeceAppName : _hebeAppName,
        'AppVersion': _isHebeCe ? _hebeceAppVersion : _hebeAppVersion,
        'CertificateId': _keyPair!.fingerprint,
        'FirebaseToken': '',
        'NotificationToken': '',
        'API': 1,
        'RequestId': const Uuid().v4(),
        'Timestamp': now.millisecondsSinceEpoch,
        'TimestampFormatted': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
        'Envelope': payload,
      };
      bodyJson = jsonEncode(envelopeBody);
    }

    final sigHeaders = HebeSigner.getSignatureHeaders(
      keyId: _keyPair!.fingerprint,
      privateKeyJson: _keyPair!.privateKey,
      body: bodyJson,
      requestPath: fullUrl,
      timestamp: now,
    );

    final headers = <String, String>{
      'User-Agent': _userAgent,
      'vOS': _deviceOs,
      'vDeviceModel': _deviceModel,
      'vVersionCode': _isHebeCe ? _hebeceVersionCode : _hebeVersionCode,
      'vAPI': '1',
      'Content-Type': bodyJson != null ? 'application/json; charset=utf-8' : 'application/json',
      if (pupilId != null) 'vHint': pupilId.toString(),
      ...sigHeaders,
    };

    dynamic rawResponse;
    if (kIsWeb && _proxyUrl.isNotEmpty) {
      final proxyRes = await _dio.post(
        _proxyUrl,
        data: jsonEncode({
          'uri': fullUrl,
          'method': method,
          'headers': headers,
          'data': bodyJson,
        }),
      );
      rawResponse = proxyRes.data is Map ? (proxyRes.data['data'] ?? proxyRes.data) : proxyRes.data;
    } else {
      final res = await _dio.request(
        fullUrl,
        data: bodyJson,
        options: Options(method: method, headers: headers),
      );
      rawResponse = res.data;
    }

    if (rawResponse is Map && rawResponse.length == 1 && rawResponse['text'] is String) {
      rawResponse = rawResponse['text'];
    }

    final Map<String, dynamic> decoded =
        rawResponse is String ? jsonDecode(rawResponse) as Map<String, dynamic> : Map<String, dynamic>.from(rawResponse as Map);
    final status = decoded['Status'] as Map?;
    final code = (status?['Code'] as num?)?.toInt() ?? 0;
    final envelope = decoded['Envelope'];
    debugPrint('[vulcan] $method $endpoint -> code=$code '
        '${envelope is List ? 'items=${envelope.length}' : envelope.runtimeType}'
        '${code != 0 ? ' msg=${status?['Message']}' : ''}');
    if (code != 0) {
      throw Exception('VULCAN API error ($code): ${status?['Message'] ?? 'Unknown'}');
    }
    return envelope;
  }

  DateTime? _tryParseVulcanDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      final intVal = value.toInt();
      if (intVal <= 0) return null;
      if (intVal < 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intVal * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(intVal);
    }
    if (value is String) {
      final str = value.trim();
      if (str.isEmpty) return null;
      final numVal = num.tryParse(str);
      if (numVal != null && numVal > 100000000) {
        return _tryParseVulcanDate(numVal);
      }
      final isoParsed = DateTime.tryParse(str);
      if (isoParsed != null) return isoParsed;
      final dmMatch = RegExp(r'^(\d{1,2})[.-](\d{1,2})[.-](\d{4})(?:\s+(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?').firstMatch(str);
      if (dmMatch != null) {
        final d = int.parse(dmMatch.group(1)!);
        final m = int.parse(dmMatch.group(2)!);
        final y = int.parse(dmMatch.group(3)!);
        final h = dmMatch.group(4) != null ? int.parse(dmMatch.group(4)!) : 0;
        final min = dmMatch.group(5) != null ? int.parse(dmMatch.group(5)!) : 0;
        final s = dmMatch.group(6) != null ? int.parse(dmMatch.group(6)!) : 0;
        return DateTime(y, m, d, h, min, s);
      }
      return null;
    }
    if (value is Map) {
      for (final tsKey in ['Timestamp', 'timestamp', 'Time', 'time']) {
        final ts = value[tsKey];
        if (ts is num && ts > 100000000) {
          return _tryParseVulcanDate(ts);
        }
      }
      for (final dateKey in ['Date', 'date', 'DateAt', 'dateAt', 'DayAt', 'dayAt', 'DeadlineAt', 'deadlineAt', 'Value', 'value', 'Day', 'day', 'DateFormatted', 'dateFormatted', 'Deadline', 'deadline']) {
        final inner = value[dateKey];
        if (inner != null) {
          final res = _tryParseVulcanDate(inner);
          if (res != null) {
            final timePart = value['Time'] ?? value['time'];
            if (timePart is String && timePart.contains(':')) {
              final tp = timePart.split(':');
              final h = int.tryParse(tp[0]) ?? 0;
              final m = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
              final s = int.tryParse(tp.length > 2 ? tp[2] : '0') ?? 0;
              return DateTime(res.year, res.month, res.day, h, m, s);
            }
            return res;
          }
        }
      }
    }
    return null;
  }

  DateTime _parseVulcanDate(dynamic value, [DateTime? fallback]) {
    return _tryParseVulcanDate(value) ?? fallback ?? DateTime.now();
  }

  models.Teacher _parseTeacher(dynamic raw) {
    if (raw is! Map) return const models.Teacher();
    return models.Teacher(
      id: (raw['Id'] as num?)?.toInt() ?? -1,
      firstName: raw['Name']?.toString() ?? '',
      lastName: raw['Surname']?.toString() ?? raw['DisplayName']?.toString() ?? '',
    );
  }

  @override
  Future<({bool success, Exception? message})> refresh({
    DateTime? weekStart,
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    if (_fakeReader != null) {
      dataChunk = _fakeReader!.registerData!;
      return _fakeReader!.refresh(weekStart: weekStart, progress: progress);
    }
    if (_restUrl == null || _activeStudentRaw == null) {
      return (success: false, message: Exception('C5FDD0D8-771D-4DCE-8FCE-62D1BA4A6C93'.localized));
    }

    try {
      progress?.report((progress: 0.1, message: '9395EE9D-253E-4795-9F7D-DFA49D161EA8'.localized));

      final studentRaw = _activeStudentRaw!;
      final pupilRaw = Map<String, dynamic>.from((studentRaw['Pupil'] as Map?) ?? {});
      final unitRaw = Map<String, dynamic>.from((studentRaw['Unit'] as Map?) ?? {});
      final constituentRaw = Map<String, dynamic>.from((studentRaw['ConstituentUnit'] as Map?) ?? {});
      final journalRaw = Map<String, dynamic>.from((studentRaw['Journal'] as Map?) ?? {});
      final periodsRaw = (studentRaw['Periods'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

      final pupilId = (pupilRaw['Id'] as num?)?.toInt() ?? -1;
      final unitId = (unitRaw['Id'] as num?)?.toInt() ?? -1;
      final constituentId = (constituentRaw['Id'] as num?)?.toInt() ?? unitId;

      final currentPeriod = periodsRaw.firstWhereOrDefault((p) => p['Current'] == true, defaultValue: periodsRaw.firstOrDefault());
      final periodId = (currentPeriod?['Id'] as num?)?.toInt() ?? -1;
      final periodNumber = (currentPeriod?['Number'] as num?)?.toInt() ?? 1;

      final beginSchoolYear = _parseVulcanDate(
        journalRaw['StartAt'] ?? periodsRaw.firstOrDefault()?['StartAt'] ?? periodsRaw.firstOrDefault()?['Start'],
        DateTime(DateTime.now().month >= 9 ? DateTime.now().year : DateTime.now().year - 1, 9, 1),
      );
      final endFirstSemester = _parseVulcanDate(
        periodsRaw.firstWhereOrDefault((p) => p['Number'] == 1)?['EndAt'] ??
            periodsRaw.firstWhereOrDefault((p) => p['Number'] == 1)?['End'],
        DateTime(beginSchoolYear.year + 1, 1, 31),
      );
      final endSchoolYear = _parseVulcanDate(
        journalRaw['EndAt'] ?? periodsRaw.lastOrDefault()?['EndAt'] ?? periodsRaw.lastOrDefault()?['End'],
        DateTime(beginSchoolYear.year + 1, 6, 25),
      );

      // Fetch lucky number
      int? luckyNumber;
      try {
        final luckyEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/school/lucky',
          pupilId: pupilId,
          query: {
            'pupilId': pupilId.toString(),
            'constituentId': constituentId.toString(),
            'day': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          },
        );
        if (luckyEnv is Map) {
          final numVal = (luckyEnv['Number'] as num?)?.toInt();
          if (numVal != null && numVal > 0) luckyNumber = numVal;
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      // Fetch timeslots
      final lessonRanges = <models.LessonRanges>[];
      try {
        final slotsEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/dictionary/timeslot',
          pupilId: pupilId,
          query: {'pupilId': pupilId.toString()},
        );
        if (slotsEnv is List) {
          for (final s in slotsEnv) {
            if (s is Map) {
              final startParts = (s['Start']?.toString() ?? '08:00').split(':');
              final endParts = (s['End']?.toString() ?? '08:45').split(':');
              lessonRanges.add(models.LessonRanges(
                from: DateTime(2000, 1, 1, int.tryParse(startParts[0]) ?? 8, int.tryParse(startParts.elementAtOrNull(1) ?? '0') ?? 0),
                to: DateTime(2000, 1, 1, int.tryParse(endParts[0]) ?? 8, int.tryParse(endParts.elementAtOrNull(1) ?? '45') ?? 45),
              ));
            }
          }
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      // Fetch announcements
      final announcements = <models.Announcement>[];
      try {
        final annEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/announcement/byPupil',
          pupilId: pupilId,
          query: {
            'unitId': unitId.toString(),
            'pupilId': pupilId.toString(),
            'view': '6',
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
        if (annEnv is List) {
          for (final a in annEnv) {
            if (a is Map) {
              announcements.add(models.Announcement(
                id: (a['Id'] as num?)?.toInt() ?? -1,
                subject: a['Title']?.toString() ?? '',
                content: a['Content']?.toString() ?? '',
                startDate: _parseVulcanDate(a['From'] ?? a['CreatedAt']),
                endDate: _parseVulcanDate(a['To'] ?? a['ModifiedAt']),
                contact: _parseTeacher(a['Sender']),
                read: false,
              ));
            }
          }
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      final unit = models.Unit(
        id: unitId,
        luckyNumber: luckyNumber,
        name: unitRaw['Short']?.toString() ?? unitRaw['DisplayName']?.toString() ?? 'VULCAN',
        fullName: unitRaw['Name']?.toString() ?? constituentRaw['Name']?.toString() ?? 'SzkoÅ‚a VULCAN',
        address: unitRaw['Address']?.toString() ?? constituentRaw['Address']?.toString() ?? '',
        lessonsRange: lessonRanges,
        announcements: announcements,
      );

      final classDisplay = studentRaw['ClassDisplay']?.toString() ?? '';
      final mainClass = models.Class(
        id: unitId,
        number: (currentPeriod?['Level'] as num?)?.toInt() ?? 1,
        symbol: classDisplay,
        name: classDisplay,
        beginSchoolYear: beginSchoolYear,
        endFirstSemester: endFirstSemester,
        endSchoolYear: endSchoolYear,
        unit: unit,
        events: [],
      );

      progress?.report((progress: 0.35, message: '7526392B-307D-4306-B5E7-D9627277B257'.localized));

      // Fetch grades and build subjects map
      final subjectsById = <int, models.Lesson>{};
      models.Lesson ensureSubject(dynamic rawSub, [models.Teacher? fallbackTeacher]) {
        if (rawSub is! Map) {
          return subjectsById.putIfAbsent(-1, () => models.Lesson(id: -1, name: 'Przedmiot', hostClass: mainClass));
        }
        final id = (rawSub['Id'] as num?)?.toInt() ?? -1;
        return subjectsById.putIfAbsent(
          id,
          () => models.Lesson(
            id: id,
            name: rawSub['Name']?.toString() ?? 'Przedmiot',
            short: rawSub['Kod']?.toString() ?? rawSub['Code']?.toString() ?? '',
            no: (rawSub['Position'] as num?)?.toInt() ?? id,
            hostClass: mainClass,
            teacher: fallbackTeacher ?? const models.Teacher(),
            grades: [],
          ),
        );
      }

      String normalizeGradeValue(String raw) {
        var v = raw.trim();
        if (v.startsWith('+') && v.length > 1) {
          v = '${v.substring(1)}+';
        } else if (v.startsWith('-') && v.length > 1) {
          v = '${v.substring(1)}-';
        }
        return v;
      }

      final periodsToQuery = periodsRaw.isNotEmpty ? periodsRaw : [currentPeriod];
      for (final period in periodsToQuery) {
        if (period == null) continue;
        final pId = (period['Id'] as num?)?.toInt() ?? periodId;
        final pNum = (period['Number'] as num?)?.toInt() ?? periodNumber;
        if (pId == -1) continue;

        try {
          final gradesEnv = await _hebeRequest(
            method: 'GET',
            restUrl: _restUrl!,
            endpoint: 'mobile/grade/byPupil',
            pupilId: pupilId,
            query: {
              'unitId': unitId.toString(),
              'pupilId': pupilId.toString(),
              'periodId': pId.toString(),
              'lastId': '-2147483648',
              'pageSize': '500',
            },
          );
          if (gradesEnv is List) {
            for (final g in gradesEnv) {
              if (g is Map) {
                final column = Map<String, dynamic>.from((g['Column'] as Map?) ?? {});
                final teacher = _parseTeacher(g['Creator'] ?? g['Modifier']);
                final subject = ensureSubject(column['Subject'], teacher);
                final weight = ((column['Weight'] as num?)?.toDouble() ?? 0.0).round();
                final comment = g['Comment']?.toString() ?? '';
                final rawVal = g['Content']?.toString() ?? g['ContentRaw']?.toString() ?? '';
                final normVal = normalizeGradeValue(rawVal);
                final countsToAvg = column['CountToAverage'] == true ||
                    column['CountsToAverage'] == true ||
                    (g['Value'] != null && weight > 0);

                final gradeId = (g['Id'] as num?)?.toInt() ?? -1;
                if (!subject.grades.any((existing) => existing.id == gradeId && gradeId > 0)) {
                  subject.grades.add(models.Grade(
                    id: gradeId,
                    name: (column['Name']?.toString().isNotEmpty ?? false)
                        ? column['Name'].toString()
                        : (column['Code']?.toString() ?? 'Ocena'),
                    value: normVal,
                    weight: weight,
                    comments: comment.isNotEmpty ? [comment] : [],
                    countsToAverage: countsToAvg,
                    date: _parseVulcanDate(g['DateCreated']),
                    addDate: _parseVulcanDate(g['DateModify'] ?? g['DateCreated']),
                    addedBy: teacher,
                    semester: pNum,
                    isConstituent: true,
                  ));
                }
              }
            }
          }
        } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

        // Fetch grade summaries (semester/final & propositions)
        try {
          final sumEnv = await _hebeRequest(
            method: 'GET',
            restUrl: _restUrl!,
            endpoint: 'mobile/grade/summary/byPupil',
            pupilId: pupilId,
            query: {
              'unitId': unitId.toString(),
              'pupilId': pupilId.toString(),
              'periodId': pId.toString(),
              'lastId': '-2147483648',
              'pageSize': '500',
            },
          );
          if (sumEnv is List) {
            for (final s in sumEnv) {
              if (s is Map) {
                final subject = ensureSubject(s['Subject']);
                final entry1 = normalizeGradeValue(s['Entry_1']?.toString().trim() ?? '');
                final entry2 = normalizeGradeValue(s['Entry_2']?.toString().trim() ?? '');
                final isLastPeriod = period['Last'] == true || pNum >= 2;
                final baseSummaryId = ((s['Id'] as num?)?.toInt() ?? 0) * 10;
                if (entry1.isNotEmpty && !subject.grades.any((existing) => existing.id == baseSummaryId + 1)) {
                  subject.grades.add(models.Grade(
                    id: baseSummaryId + 1,
                    name: isLastPeriod ? 'Propozycja oceny rocznej' : 'Propozycja oceny Å›rÃ³drocznej',
                    value: entry1,
                    semester: pNum,
                    isSemesterProposition: !isLastPeriod,
                    isFinalProposition: isLastPeriod,
                    date: _parseVulcanDate(s['ModifiedAt']),
                    addDate: _parseVulcanDate(s['ModifiedAt']),
                  ));
                }
                if (entry2.isNotEmpty && !subject.grades.any((existing) => existing.id == baseSummaryId + 2)) {
                  subject.grades.add(models.Grade(
                    id: baseSummaryId + 2,
                    name: isLastPeriod ? 'Ocena roczna' : 'Ocena Å›rÃ³droczna',
                    value: entry2,
                    semester: pNum,
                    isSemester: !isLastPeriod,
                    isFinal: isLastPeriod,
                    date: _parseVulcanDate(s['ModifiedAt']),
                    addDate: _parseVulcanDate(s['ModifiedAt']),
                  ));
                }
              }
            }
          }
        } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }
      }

      progress?.report((progress: 0.6, message: '7344559E-3869-4BDA-AD38-266302B3D929'.localized));

      // Date window for schedule: 35 days before, 42 days after pivot
      final pivot = weekStart ?? DateTime.now();
      final schedDateFrom = DateFormat('yyyy-MM-dd').format(pivot.subtract(const Duration(days: 35)));
      final schedDateTo = DateFormat('yyyy-MM-dd').format(pivot.add(const Duration(days: 42)));

      // Fetch schedule with changes
      final timetableMap = <DateTime, models.TimetableDay>{...dataChunk.timetables.timetable};
      try {
        final schedEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/schedule/withchanges/byPupil',
          pupilId: pupilId,
          query: {
            'pupilId': pupilId.toString(),
            'dateFrom': schedDateFrom,
            'dateTo': schedDateTo,
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
        if (schedEnv is List) {
          final byDay = <DateTime, Map<int, List<models.TimetableLesson>>>{};
          for (final item in schedEnv) {
            if (item is! Map) continue;
            if (item['Visible'] == false) continue;

            final rawDate = _parseVulcanDate(item['DateAt'] ?? item['Date']);
            // NOTE: Must be LOCAL DateTime so it matches timetable.dart and home.dart map lookups!
            final dayKey = DateTime(rawDate.year, rawDate.month, rawDate.day);
            final slot = Map<String, dynamic>.from((item['TimeSlot'] as Map?) ?? {});
            final lessonNo = (slot['Position'] as num?)?.toInt() ?? 1;
            final startParts = (slot['Start']?.toString() ?? '08:00').split(':');
            final endParts = (slot['End']?.toString() ?? '08:45').split(':');
            final hourFrom = DateTime(
              dayKey.year,
              dayKey.month,
              dayKey.day,
              int.tryParse(startParts[0]) ?? 8,
              int.tryParse(startParts.elementAtOrNull(1) ?? '0') ?? 0,
            );
            final hourTo = DateTime(
              dayKey.year,
              dayKey.month,
              dayKey.day,
              int.tryParse(endParts[0]) ?? 8,
              int.tryParse(endParts.elementAtOrNull(1) ?? '45') ?? 45,
            );

            final sub = item['Substitution'] as Map?;
            final change = (sub?['Change'] ?? item['Change']) as Map?;
            final changeType = (change?['Type'] as num?)?.toInt();
            // Type 1 or 4 in Vulcan Hebe indicates cancelled / moved away lesson
            final isCanceled = changeType == 1 || changeType == 4 || sub?['ClassAbsence'] == true;
            final modifiedSchedule = sub != null || change != null;

            final effectiveSubjectMap = sub?['Subject'] ?? item['Subject'];
            final effectiveTeacherMap = sub?['TeacherPrimary'] ?? item['TeacherPrimary'];
            final effectiveRoomMap = sub?['Room'] ?? item['Room'];

            final teacher = _parseTeacher(effectiveTeacherMap);
            final subject = ensureSubject(effectiveSubjectMap, teacher);
            final roomCode = (effectiveRoomMap is Map) ? (effectiveRoomMap['Code']?.toString() ?? '') : '';

            models.SubstitutionDetails? subDetails;
            if (modifiedSchedule) {
              subDetails = models.SubstitutionDetails(
                originalDate: dayKey,
                originalLessonNo: lessonNo,
                originalSubject: ensureSubject(item['Subject']),
                originalTeacher: _parseTeacher(item['TeacherPrimary']),
              );
            }

            final lessonObj = models.TimetableLesson(
              lessonNo: lessonNo,
              isCanceled: isCanceled,
              lessonClass: mainClass,
              subject: subject,
              teacher: teacher,
              classroom: models.Classroom(name: roomCode, symbol: roomCode),
              modifiedSchedule: modifiedSchedule,
              substitutionNote: sub?['Reason']?.toString() ?? sub?['PupilNote']?.toString() ?? item['Event']?.toString(),
              substitutionDetails: subDetails,
              date: dayKey,
              hourFrom: hourFrom,
              hourTo: hourTo,
            );

            final daySlots = byDay.putIfAbsent(dayKey, () => {});
            daySlots.putIfAbsent(lessonNo, () => []).add(lessonObj);
          }

          byDay.forEach((dayKey, slotsMap) {
            final maxSlot = slotsMap.keys.isEmpty ? 0 : slotsMap.keys.reduce((a, b) => a > b ? a : b);
            final list = List<List<models.TimetableLesson>?>.generate(
              maxSlot + 1,
              (idx) => slotsMap[idx],
            );
            timetableMap[dayKey] = models.TimetableDay(lessons: list, calendarDay: dayKey);
          });
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      progress?.report((progress: 0.8, message: '10B640EC-6CBF-42CF-A20B-7CA5E97E8AFE'.localized));

      // Fetch attendance
      final attendances = <models.Attendance>[];
      try {
        final attEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/lesson/byPupil',
          pupilId: pupilId,
          query: {
            'pupilId': pupilId.toString(),
            'dateFrom': DateFormat('yyyy-MM-dd').format(beginSchoolYear),
            'dateTo': DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 2))),
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
        if (attEnv is List) {
          for (final a in attEnv) {
            if (a is! Map) continue;
            final presence = a['PresenceType'] as Map?;
            if (presence == null || presence['Removed'] == true) continue;

            models.AttendanceType attType = models.AttendanceType.other;
            if (presence['Presence'] == true) {
              attType = models.AttendanceType.present;
            } else if (presence['Late'] == true) {
              attType = models.AttendanceType.late;
            } else if (presence['AbsenceJustified'] == true) {
              attType = models.AttendanceType.excused;
            } else if (presence['LegalAbsence'] == true) {
              attType = models.AttendanceType.duty;
            } else if (presence['Absence'] == true) {
              attType = models.AttendanceType.absent;
            }

            final date = _tryParseVulcanDate(a['DayAt']) ??
                _tryParseVulcanDate(a['Date']) ??
                _tryParseVulcanDate(a['DateAt']) ??
                _tryParseVulcanDate(a['Day']) ??
                _tryParseVulcanDate(a['LessonDate']) ??
                DateTime.now();
            final lessonNo = (a['LessonNumber'] as num?)?.toInt() ?? 1;
            final teacher = _parseTeacher(a['TeacherPrimary']);
            final subject = ensureSubject(a['Subject'], teacher);

            attendances.add(models.Attendance(
              id: (a['Id'] as num?)?.toInt() ?? -1,
              lessonNo: lessonNo,
              date: DateTime(date.year, date.month, date.day),
              addDate: _tryParseVulcanDate(a['ModifiedAt']) ??
                  _tryParseVulcanDate(a['DateModify']) ??
                  _tryParseVulcanDate(a['Date']) ??
                  date,
              type: attType,
              teacher: teacher,
              lesson: models.TimetableLesson(
                lessonNo: lessonNo,
                subject: subject,
                teacher: teacher,
                date: DateTime(date.year, date.month, date.day),
              ),
            ));
          }
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      // Fetch exams & homeworks (entire school year range)
      final eventsDateFrom = DateFormat('yyyy-MM-dd').format(beginSchoolYear);
      final eventsDateTo = DateFormat('yyyy-MM-dd').format(endSchoolYear.add(const Duration(days: 14)));

      final events = <models.Event>[];
      try {
        final examsEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/exam/byPupil',
          pupilId: pupilId,
          query: {
            'pupilId': pupilId.toString(),
            'dateFrom': eventsDateFrom,
            'dateTo': eventsDateTo,
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
        if (examsEnv is List) {
          for (final ex in examsEnv) {
            if (ex is! Map) continue;
            final typeStr = ex['Type']?.toString() ?? 'Sprawdzian';
            final deadline = _tryParseVulcanDate(ex['DeadlineAt']) ??
                _tryParseVulcanDate(ex['Deadline']) ??
                _tryParseVulcanDate(ex['Date']) ??
                _tryParseVulcanDate(ex['DateAt']) ??
                _tryParseVulcanDate(ex['DayAt']) ??
                _tryParseVulcanDate(ex['Day']) ??
                _tryParseVulcanDate(ex['CreatedAt']) ??
                _tryParseVulcanDate(ex['DateCreated']) ??
                beginSchoolYear;
            final created = _tryParseVulcanDate(ex['CreatedAt']) ??
                _tryParseVulcanDate(ex['DateCreated']) ??
                _tryParseVulcanDate(ex['ModifiedAt']) ??
                _tryParseVulcanDate(ex['DateModify']) ??
                deadline;
            final subject = ensureSubject(ex['Subject']);
            final cat = typeStr.toLowerCase().contains('kartk')
                ? models.EventCategory.shortTest
                : typeStr.toLowerCase().contains('klasow')
                    ? models.EventCategory.classWork
                    : models.EventCategory.test;
            events.add(models.Event(
              id: (ex['Id'] as num?)?.toInt() ?? -1,
              date: DateTime(deadline.year, deadline.month, deadline.day),
              addDate: created,
              timeFrom: deadline,
              title: '${subject.name} \u2022 $typeStr',
              content: ex['Content']?.toString() ?? typeStr,
              categoryName: typeStr,
              category: cat,
              sender: _parseTeacher(ex['Creator']),
            ));
          }
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      try {
        final hwEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/homework/byPupil',
          pupilId: pupilId,
          query: {
            'pupilId': pupilId.toString(),
            'dateFrom': eventsDateFrom,
            'dateTo': eventsDateTo,
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
        if (hwEnv is List) {
          for (final hw in hwEnv) {
            if (hw is! Map) continue;
            final deadline = _tryParseVulcanDate(hw['DeadlineAt']) ??
                _tryParseVulcanDate(hw['Deadline']) ??
                _tryParseVulcanDate(hw['DateAt']) ??
                _tryParseVulcanDate(hw['Date']) ??
                _tryParseVulcanDate(hw['AnswerAt']) ??
                _tryParseVulcanDate(hw['AnswerDeadline']) ??
                _tryParseVulcanDate(hw['DayAt']) ??
                _tryParseVulcanDate(hw['Day']) ??
                _tryParseVulcanDate(hw['CreatedAt']) ??
                _tryParseVulcanDate(hw['DateCreated']) ??
                beginSchoolYear;
            final created = _tryParseVulcanDate(hw['DateAt']) ??
                _tryParseVulcanDate(hw['CreatedAt']) ??
                _tryParseVulcanDate(hw['DateCreated']) ??
                _tryParseVulcanDate(hw['ModifiedAt']) ??
                _tryParseVulcanDate(hw['DateModify']) ??
                deadline;
            final subject = ensureSubject(hw['Subject']);
            events.add(models.Event(
              id: (hw['Id'] as num?)?.toInt() ?? -1,
              date: DateTime(deadline.year, deadline.month, deadline.day),
              addDate: created,
              timeFrom: deadline,
              timeTo: deadline,
              title: subject.name,
              content: hw['Content']?.toString() ?? '',
              categoryName: 'Zadanie domowe',
              category: models.EventCategory.homework,
              done: hw['AnswerDate'] != null,
              sender: _parseTeacher(hw['Creator']),
            ));
          }
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      mainClass.events = events;

      String firstName = pupilRaw['FirstName']?.toString() ?? '';
      String lastName = pupilRaw['Surname']?.toString() ?? pupilRaw['LastName']?.toString() ?? '';
      if (firstName.isEmpty && pupilRaw['DisplayName'] != null) {
        final parts = pupilRaw['DisplayName'].toString().trim().split(' ');
        if (parts.isNotEmpty) firstName = parts.first;
        if (parts.length > 1) lastName = parts.sublist(1).join(' ');
      }
      if (firstName.isEmpty) firstName = pupilRaw['Name']?.toString() ?? 'UczeÅ„';

      final pupilNumber = (journalRaw['PupilNumber'] as num?)?.toInt() ??
          (studentRaw['PupilNumber'] as num?)?.toInt() ??
          (pupilRaw['Number'] as num?)?.toInt() ??
          (pupilRaw['PupilNumber'] as num?)?.toInt() ??
          1;

      dataChunk.student = models.Student(
        account: models.Account(
          id: pupilId,
          userId: (pupilRaw['LoginId'] as num?)?.toInt() ?? pupilId,
          number: pupilNumber,
          firstName: firstName,
          lastName: lastName,
        ),
        mainClass: mainClass,
        subjects: subjectsById.values.toList(),
        attendances: attendances,
      );
      dataChunk.timetables = models.Timetables(timetable: timetableMap);

      return (success: true, message: null);
    } on Exception catch (ex, st) {
      debugPrint('[vulcan] FAILED: $ex\n$st');
      return (success: false, message: ex);
    } catch (ex, st) {
      debugPrint('[vulcan] FAILED(error): $ex\n$st');
      return (success: false, message: Exception(ex.toString()));
    }
  }

  @override
  Future<({bool success, Exception? message})> refreshMessages({
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    if (_fakeReader != null) {
      dataChunk = _fakeReader!.registerData!;
      return _fakeReader!.refreshMessages(progress: progress);
    }
    if (_restUrl == null || _activeStudentRaw == null) {
      return (success: false, message: Exception('C5FDD0D8-771D-4DCE-8FCE-62D1BA4A6C93'.localized));
    }

    try {
      progress?.report((progress: 0.2, message: '135991AA-5B53-42EA-8A2B-5406B249CC40'.localized));
      final pupilId = (_activeStudentRaw!['Pupil']?['Id'] as num?)?.toInt() ?? -1;
      final boxKey = _activeStudentRaw!['MessageBox']?['GlobalKey']?.toString() ?? '';
      if (boxKey.isEmpty) {
        dataChunk.messages = models.Messages(receivers: [], received: [], sent: []);
        return (success: true, message: null);
      }

      final receivers = <models.Teacher>[];
      try {
        final addrEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/addressbook',
          pupilId: pupilId,
          query: {'box': boxKey},
        );
        if (addrEnv is List) {
          for (var i = 0; i < addrEnv.length; i++) {
            final entry = addrEnv[i];
            if (entry is Map) {
              receivers.add(models.Teacher(
                id: i + 1,
                url: entry['GlobalKey']?.toString() ?? '',
                firstName: entry['Name']?.toString() ?? '',
                lastName: entry['Group']?.toString() ?? '',
              ));
            }
          }
        }
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      List<models.Message> mapMessages(dynamic env, {required bool sent}) {
        if (env is! List) return [];
        final out = <models.Message>[];
        for (final m in env) {
          if (m is! Map) continue;
          final senderMap = m['Sender'] as Map?;
          final recList = (m['Receiver'] as List?) ?? [];
          final attachmentsRaw = (m['Attachments'] as List?) ?? [];
          final content = m['Content']?.toString() ?? '';
          out.add(models.Message(
            id: m['Id']?.toString().hashCode ?? m['GlobalKey']?.toString().hashCode ?? -1,
            url: m['GlobalKey']?.toString() ?? '',
            topic: m['Subject']?.toString() ?? '',
            content: content,
            preview: content,
            sendDate: _parseVulcanDate(m['DateSent']),
            readDate: m['DateRead'] != null ? _parseVulcanDate(m['DateRead']) : null,
            hasAttachments: attachmentsRaw.isNotEmpty,
            attachments: attachmentsRaw
                .whereType<Map>()
                .map((a) => models.Attachment(
                      name: a['Name']?.toString() ?? 'ZaÅ‚Ä…cznik',
                      location: a['Link']?.toString() ?? '',
                    ))
                .toList(),
            sender: sent
                ? null
                : models.Teacher(
                    firstName: senderMap?['Name']?.toString() ?? 'Nadawca',
                    url: senderMap?['GlobalKey']?.toString() ?? '',
                  ),
            receivers: sent
                ? recList
                    .whereType<Map>()
                    .map((r) => models.Teacher(
                          firstName: r['Name']?.toString() ?? '',
                          url: r['GlobalKey']?.toString() ?? '',
                        ))
                    .toList()
                : null,
          ));
        }
        return out;
      }

      dynamic inboxEnv;
      try {
        inboxEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/messages/received/byBox',
          pupilId: pupilId,
          query: {
            'box': boxKey,
            'pupilId': pupilId.toString(),
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      dynamic sentEnv;
      try {
        sentEnv = await _hebeRequest(
          method: 'GET',
          restUrl: _restUrl!,
          endpoint: 'mobile/messages/sent/byBox',
          pupilId: pupilId,
          query: {
            'box': boxKey,
            'pupilId': pupilId.toString(),
            'lastId': '-2147483648',
            'pageSize': '500',
          },
        );
      } catch (vex, vst) { debugPrint('[vulcan] swallowed error: $vex\n$vst'); }

      List<models.Message> received = mapMessages(inboxEnv, sent: false);
      List<models.Message> sent = mapMessages(sentEnv, sent: true);

      // Web fallback when mobile Hebe API returns code 111 (EDUVULCAN_PREMIUM) or empty
      debugPrint('[vulcan] web messages fallback: received=${received.length}, user=$_savedUsername, hasPass=${_savedPassword?.isNotEmpty}, part=$_topLevelPartition');
      if (received.isEmpty && kIsWeb && _proxyUrl.isNotEmpty && _topLevelPartition.isNotEmpty) {
        try {
          final webInboxRes = await _dio.post(
            _proxyUrl,
            data: jsonEncode({
              'action': 'eduvulcan_fetch_messages',
              'login': _savedUsername ?? '',
              'password': _savedPassword ?? '',
              'partition': _topLevelPartition,
              'folder': 'Odebrane',
              'idLastWiadomosc': 0,
              'pageSize': 50,
            }),
          );
          final rawData = webInboxRes.data is Map ? (webInboxRes.data['data'] ?? webInboxRes.data) : webInboxRes.data;
          final rawList = rawData is List ? rawData : (rawData is Map && rawData['data'] is List ? rawData['data'] as List : null);
          if (rawList != null) {
            final webReceived = <models.Message>[];
            for (final m in rawList) {
              if (m is! Map) continue;
              final msgId = (m['id'] as num?)?.toInt() ?? (m['apiGlobalKey']?.toString().hashCode ?? -1);
              final dateParsed = _tryParseVulcanDate(m['data']) ?? DateTime.now();
              final isRead = m['przeczytana'] == true;
              webReceived.add(models.Message(
                id: msgId,
                url: m['apiGlobalKey']?.toString() ?? msgId.toString(),
                topic: m['temat']?.toString() ?? '(Bez tematu)',
                content: m['tresc']?.toString() ?? '',
                preview: m['tresc']?.toString() ?? m['temat']?.toString() ?? '',
                sendDate: dateParsed,
                readDate: isRead ? dateParsed : null,
                hasAttachments: m['hasZalaczniki'] == true,
                attachments: [],
                sender: models.Teacher(
                  firstName: m['korespondenci']?.toString() ?? 'Nadawca',
                  url: m['apiGlobalKey']?.toString() ?? '',
                ),
              ));
            }
            if (webReceived.isNotEmpty) {
              received = webReceived;
            }
          }
        } catch (vex, vst) {
          debugPrint('[vulcan] web messages fallback failed: $vex\n$vst');
        }

        try {
          final webSentRes = await _dio.post(
            _proxyUrl,
            data: jsonEncode({
              'action': 'eduvulcan_fetch_messages',
              'login': _savedUsername ?? '',
              'password': _savedPassword ?? '',
              'partition': _topLevelPartition,
              'folder': 'Wyslane',
              'idLastWiadomosc': 0,
              'pageSize': 50,
            }),
          );
          final rawData = webSentRes.data is Map ? (webSentRes.data['data'] ?? webSentRes.data) : webSentRes.data;
          final rawList = rawData is List ? rawData : (rawData is Map && rawData['data'] is List ? rawData['data'] as List : null);
          if (rawList != null) {
            final webSent = <models.Message>[];
            for (final m in rawList) {
              if (m is! Map) continue;
              final msgId = (m['id'] as num?)?.toInt() ?? (m['apiGlobalKey']?.toString().hashCode ?? -1);
              final dateParsed = _tryParseVulcanDate(m['data']) ?? DateTime.now();
              webSent.add(models.Message(
                id: msgId,
                url: m['apiGlobalKey']?.toString() ?? msgId.toString(),
                topic: m['temat']?.toString() ?? '(Bez tematu)',
                content: m['tresc']?.toString() ?? '',
                preview: m['tresc']?.toString() ?? m['temat']?.toString() ?? '',
                sendDate: dateParsed,
                readDate: dateParsed,
                hasAttachments: m['hasZalaczniki'] == true,
                attachments: [],
                receivers: [
                  models.Teacher(
                    firstName: m['korespondenci']?.toString() ?? 'Odbiorca',
                    url: m['apiGlobalKey']?.toString() ?? '',
                  )
                ],
              ));
            }
            if (webSent.isNotEmpty) {
              sent = webSent;
            }
          }
        } catch (vex, vst) {
          debugPrint('[vulcan] web sent messages fallback failed: $vex\n$vst');
        }
      }

      if (receivers.isEmpty) {
        final uniqueTeachers = <String, models.Teacher>{};
        for (final m in received) {
          if (m.sender != null && m.sender!.name.isNotEmpty) {
            uniqueTeachers.putIfAbsent(m.sender!.name, () => m.sender!);
          }
        }
        receivers.addAll(uniqueTeachers.values);
      }

      dataChunk.messages = models.Messages(
        receivers: receivers,
        received: received,
        sent: sent,
      );

      return (success: true, message: null);
    } catch (_) {
      dataChunk.messages = models.Messages(receivers: [], received: [], sent: []);
      return (success: true, message: null);
    }
  }

  @override
  Future<({bool success, Exception? message})> sendMessage({
    required List<models.Teacher> receivers,
    required String topic,
    required String content,
  }) async {
    if (_fakeReader != null) {
      return _fakeReader!.sendMessage(receivers: receivers, topic: topic, content: content);
    }
    try {
      final pupilId = (_activeStudentRaw?['Pupil']?['Id'] as num?)?.toInt();
      final boxKey = _activeStudentRaw?['MessageBox']?['GlobalKey']?.toString() ?? '';
      final senderName = _activeStudentRaw?['MessageBox']?['Name']?.toString() ?? dataChunk.student.account.name;
      await _hebeRequest(
        method: 'POST',
        restUrl: _restUrl!,
        endpoint: 'mobile/messages',
        pupilId: pupilId,
        payload: {
          'Id': const Uuid().v4(),
          'GlobalKey': const Uuid().v4(),
          'ThreadKey': const Uuid().v4(),
          'Sender': {
            'GlobalKey': boxKey,
            'Name': senderName,
            'HasRead': 1,
          },
          'Receiver': receivers
              .map((r) => {
                    'GlobalKey': r.url,
                    'Name': r.name,
                    'HasRead': 0,
                  })
              .toList(),
          'Subject': topic,
          'Content': content,
          'DateSent': {
            'Date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'Time': DateFormat('HH:mm:ss').format(DateTime.now()),
            'Timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          'Status': 1,
          'Attachments': [],
        },
      );
      return (success: true, message: null);
    } on Exception catch (ex, st) {
      debugPrint('[vulcan] FAILED: $ex\n$st');
      return (success: false, message: ex);
    } catch (ex, st) {
      debugPrint('[vulcan] FAILED(error): $ex\n$st');
      return (success: false, message: Exception(ex.toString()));
    }
  }

  @override
  Future<({bool success, Exception? message, models.Message? result})> fetchMessageContent({
    required models.Message parent,
    required bool byMe,
  }) async {
    if (_fakeReader != null) {
      return _fakeReader!.fetchMessageContent(parent: parent, byMe: byMe);
    }
    try {
      if (!byMe && !parent.read && parent.url.isNotEmpty && _restUrl != null) {
        final pupilId = (_activeStudentRaw?['Pupil']?['Id'] as num?)?.toInt();
        final boxKey = _activeStudentRaw?['MessageBox']?['GlobalKey']?.toString() ?? '';
        await _hebeRequest(
          method: 'POST',
          restUrl: _restUrl!,
          endpoint: 'mobile/messages/status',
          pupilId: pupilId,
          payload: {
            'BoxKey': boxKey,
            'MessageKey': parent.url,
            'Status': 1,
          },
        );
      }
      String effectiveContent = parent.content ?? parent.preview ?? '';
      List<models.Attachment>? effectiveAttachments = parent.attachments;

      if (effectiveContent.isEmpty && kIsWeb && _proxyUrl.isNotEmpty && _topLevelPartition.isNotEmpty) {
        try {
          final detRes = await _dio.post(
            _proxyUrl,
            data: jsonEncode({
              'action': 'eduvulcan_fetch_message_content',
              'login': _savedUsername ?? '',
              'password': _savedPassword ?? '',
              'partition': _topLevelPartition,
              'id': parent.id,
              'apiGlobalKey': parent.url,
            }),
          );
          final d = detRes.data is Map ? (detRes.data['data'] ?? detRes.data) : detRes.data;
          if (d is Map) {
            final body = d['tresc']?.toString() ?? d['content']?.toString() ?? d['trescHtml']?.toString() ?? '';
            if (body.isNotEmpty) {
              effectiveContent = body;
            }
            final attachmentsRaw = (d['zalaczniki'] ?? d['Attachments']) as List?;
            if (attachmentsRaw != null && attachmentsRaw.isNotEmpty) {
              effectiveAttachments = attachmentsRaw
                  .whereType<Map>()
                  .map((a) => models.Attachment(
                        name: a['nazwa']?.toString() ?? a['Name']?.toString() ?? 'Załącznik',
                        location: a['url']?.toString() ?? a['Link']?.toString() ?? '',
                      ))
                  .toList();
            }
          }
        } catch (vex) {
          debugPrint('[vulcan] web message detail fallback error: $vex');
        }
      }

      final updated = models.Message.from(
        other: parent,
        content: effectiveContent,
        readDate: parent.readDate ?? DateTime.now(),
        attachments: effectiveAttachments,
      );
      return (success: true, message: null, result: updated);
    } on Exception catch (ex) {
      return (success: false, message: ex, result: parent);
    } catch (ex) {
      return (success: false, message: Exception(ex.toString()), result: parent);
    }
  }

  @override
  Future<({bool success, Exception? message})> moveMessageToTrash({
    required models.Message parent,
    required bool byMe,
  }) async {
    if (_fakeReader != null) {
      return _fakeReader!.moveMessageToTrash(parent: parent, byMe: byMe);
    }
    try {
      final pupilId = (_activeStudentRaw?['Pupil']?['Id'] as num?)?.toInt();
      final boxKey = _activeStudentRaw?['MessageBox']?['GlobalKey']?.toString() ?? '';
      await _hebeRequest(
        method: 'POST',
        restUrl: _restUrl!,
        endpoint: 'mobile/messages/status',
        pupilId: pupilId,
        payload: {
          'BoxKey': boxKey,
          'MessageKey': parent.url,
          'Status': 2,
        },
      );
      return (success: true, message: null);
    } on Exception catch (ex, st) {
      debugPrint('[vulcan] FAILED: $ex\n$st');
      return (success: false, message: ex);
    } catch (ex, st) {
      debugPrint('[vulcan] FAILED(error): $ex\n$st');
      return (success: false, message: Exception(ex.toString()));
    }
  }

  @override
  Future<({bool success, Exception? message})> markEventAsViewed({required models.Event parent}) async {
    if (_fakeReader != null) return _fakeReader!.markEventAsViewed(parent: parent);
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message})> markEventAsDone({required models.Event parent}) async {
    if (_fakeReader != null) return _fakeReader!.markEventAsDone(parent: parent);
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message})> markAnnouncementAsViewed({required models.Announcement parent}) async {
    if (_fakeReader != null) return _fakeReader!.markAnnouncementAsViewed(parent: parent);
    return (success: true, message: null);
  }
}
