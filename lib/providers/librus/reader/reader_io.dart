// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:format/format.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/translator.dart';
import 'package:universal_io/io.dart';
import '../constants.dart';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:oshi/providers/librus/reader/librus_reader.dart' as reader;

class SynergiaData extends reader.SynergiaData {
  SynergiaData([String pvReserved = '']) : session = Dio() {
    librusApi = LibrusReader(this);
    session.httpClientAdapter = NativeAdapter();
  }

  @override
  Dio session;

  @override
  Map<String, String> cookies = {};
  CookieJar cookieJar = CookieJar();
}

class LibrusReader extends reader.LibrusReader {
  @override
  final SynergiaData synergiaData;

  LibrusReader(this.synergiaData);

  @override
  Future<Map<String, dynamic>> request(String endpoint) async {
    try {
      return (await synergiaData.session.get(
              '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}'))
          .data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.get(
              '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}'))
          .data as Map<String, dynamic>;
    }
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, Object data) async {
    try {
      return (await synergiaData.session.post(
              '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
              options: Options(method: 'POST', headers: {
                HttpHeaders.contentTypeHeader: "application/json",
              }),
              data: data))
          .data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.post(
              '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
              options: Options(method: 'POST', headers: {
                HttpHeaders.contentTypeHeader: "application/json",
              }),
              data: data))
          .data as Map<String, dynamic>;
    }
  }

  @override
  Future<String> synergiaRequest(String endpoint) async {
    try {
      return (await synergiaData.session.get(
              '$synergiaCookieUrl/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}'))
          .data;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.get(
              '$synergiaCookieUrl/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}'))
          .data;
    }
  }

  @override
  Future<Map<String, dynamic>> messagesRequest(String endpoint) async {
    try {
      return (await synergiaData.session.get(
              '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}'))
          .data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.get(
              '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}'))
          .data as Map<String, dynamic>;
    }
  }

  @override
  Future messagesDelete(String endpoint) async {
    try {
      await synergiaData.session.delete(
          '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}');
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      await synergiaData.session.delete(
          '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}');
    }
  }

  @override
  Future<Map<String, dynamic>> messagesPost(String endpoint, Object data) async {
    try {
      return (await synergiaData.session.post(
              '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
              options: Options(method: 'POST', headers: {
                HttpHeaders.contentTypeHeader: "application/json",
              }),
              data: data))
          .data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.post(
              '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
              options: Options(method: 'POST', headers: {
                HttpHeaders.contentTypeHeader: "application/json",
              }),
              data: data))
          .data as Map<String, dynamic>;
    }
  }
}

class LibrusLogin extends reader.LibrusLogin {
  @override
  final String proxyUrl;

  @override
  final String synergiaLogin;

  @override
  final String synergiaPass;

  @override
  final SynergiaData synergiaData;

  LibrusLogin({SynergiaData? synergiaData, String? login, String? pass, String? proxyUrl})
      : synergiaData = synergiaData ?? SynergiaData(),
        synergiaLogin = login ?? '',
        synergiaPass = pass ?? '',
        proxyUrl = proxyUrl ?? 'http://127.0.0.1:80';

  String _makeBannerHeader() {
    String shiftChars(dynamic value) {
      return value.toString().split('').map((char) => String.fromCharCode(char.codeUnitAt(0) + 20)).join('');
    }
    final rand = Random().nextDouble();
    final now = DateTime.now().millisecondsSinceEpoch;
    return '${shiftChars(rand)}_${shiftChars(now)}';
  }

  @override
  Future setupToken({IProgress<({double? progress, String? message})>? progress}) async {
    // Reset the session, regenerate cookies
    synergiaData.session = Dio(BaseOptions(
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ));
    synergiaData.cookieJar = CookieJar();
    synergiaData.session.interceptors.add(CookieManager(synergiaData.cookieJar));
    progress?.report((progress: 0.25, message: '55E2F1C8-AD9E-4D3B-B700-0DB1493C8B07'.localized));

//#region OAuth Setup
    String loginUrl = librusOAuthUri;
    try {
      // 1. Initial hit to portalRodzina to establish session cookies & state token
      final portalRes = await synergiaData.session.get<String>(
        librusPortalRodzinaUri,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
          headers: const {'Referer': 'https://portal.librus.pl/'},
        ),
      );
      final redirect1 = portalRes.headers.value('location');
      if (redirect1 != null && redirect1.isNotEmpty) {
        final authUrl = redirect1.startsWith('/') ? 'https://api.librus.pl$redirect1' : redirect1;
        // 2. Fetch the state-bearing authorization URL
        final authRes = await synergiaData.session.get<String>(
          authUrl,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => status != null && status < 400,
            headers: {'Referer': librusPortalRodzinaUri},
          ),
        );
        final redirect2 = authRes.headers.value('location');
        if (redirect2 != null && redirect2.isNotEmpty) {
          loginUrl = redirect2.startsWith('/') ? 'https://api.librus.pl$redirect2' : redirect2;
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Librus portalRodzina bootstrap]: $e');
    }

    progress?.report((progress: 0.35, message: '55E2F1C8-AD9E-4D3B-B700-0DB1493C8B07'.localized));

    // Ensure login page is visited so cookies (SDZIENNIKSID, DZIENNIKSID) are primed
    try {
      await synergiaData.session.get<String>(
        loginUrl,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
          headers: {'Referer': librusPortalRodzinaUri},
        ),
      );
    } catch (_) {}

    progress?.report((progress: 0.45, message: 'C8C69498-3A64-4560-A275-3ACDCCCF1B90'.localized));

    // 3. Post credentials
    dynamic loginData;
    String? nextTarget;
    try {
      final loginRes = await synergiaData.session.post(
        loginUrl,
        data: {
          'action': 'login',
          'login': synergiaLogin,
          'pass': synergiaPass,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'x-baner': _makeBannerHeader(),
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json, text/javascript, */*; q=0.01',
            'Referer': loginUrl,
            'Origin': 'https://api.librus.pl',
          },
        ),
      );
      loginData = loginRes.data;
      nextTarget = loginRes.headers.value('location');
      if (loginData is Map) {
        if (loginData['status'] == 'error') {
          final errList = loginData['errors'];
          final errMsg = (errList is List && errList.isNotEmpty && errList[0] is Map)
              ? errList[0]['message']?.toString()
              : null;
          throw Exception(errMsg ?? 'Nieprawidłowy login i/lub hasło.');
        }
        nextTarget ??= loginData['goTo']?.toString();
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final errList = e.response?.data['errors'];
        final msg = (errList is List && errList.isNotEmpty && errList[0] is Map)
            ? errList[0]['message']?.toString()
            : null;
        throw Exception(msg ?? e.message);
      }
      rethrow;
    }

    // 4. Follow continuation chain
    progress?.report((progress: 0.55, message: '9A7C2236-A7DC-4668-81F2-FEF1FF9B0AAE'.localized));
    String currentTarget = nextTarget ?? '/OAuth/Authorization/2FA?client_id=46';
    for (int hop = 0; hop < 6; hop++) {
      final absTarget = currentTarget.startsWith('/') ? 'https://api.librus.pl$currentTarget' : currentTarget;
      try {
        final hopRes = await synergiaData.session.get<String>(
          absTarget,
          options: Options(
            followRedirects: false,
            validateStatus: (status) => status != null && status < 400,
            headers: {'Referer': loginUrl},
          ),
        );
        final loc = hopRes.headers.value('location');
        if (loc == null || loc.isEmpty) break;
        currentTarget = loc;
      } catch (_) {
        break;
      }
    }

    // Ensure OAuth grant parameters are processed
    try {
      await synergiaData.session.get(
        librusOAuthGrantUri,
        queryParameters: {'client_id': 46},
        options: Options(followRedirects: true),
      );
    } catch (_) {}
//#endregion

//#region Gateway
    // Activate the API access - get the user ID
    progress?.report((progress: 0.65, message: '41D4096F-11CA-4385-8191-436DB9BF8A07'.localized));
    var tokenResponse = await synergiaData.session.get(gatewayTokenInfoUri);

    final userIdentifier = tokenResponse.data is Map ? tokenResponse.data['UserIdentifier'] : null;
    if (userIdentifier == null) {
      throw Exception('64D1FFB7-0CF9-43D1-8B74-998F2AB6CAA6'.localized);
    }

    // Activate the API access - authenticate using the ID
    progress?.report((progress: 0.75, message: '5DA166B8-F9B9-40A1-8E90-22ED84E498A3'.localized));
    var authResponse = await synergiaData.session.get(format(gatewayTokenGrantUri, userIdentifier));

    // Validate the user still has access to the API
    if (authResponse.data is! Map || authResponse.data['UserState'] != 'ACTIVE') {
      throw Exception('64D1FFB7-0CF9-43D1-8B74-998F2AB6CAA6'.localized);
    }
//#endregion

//#region Messages
    // Make the first request - used to gain general authorization
    progress?.report((progress: 0.85, message: 'FB716D2D-FFFA-41C5-91B5-02678F6D0FA5'.localized));
    await synergiaData.session.get(messagesActivationUri);

    // Copy all cookies from the authorization session
    progress?.report((progress: 0.95, message: '4D52E8BC-6C25-4C8F-B031-777844C73315'.localized));
    synergiaData.cookieJar.saveFromResponse(
        Uri.parse(messagesCookieUrl), await synergiaData.cookieJar.loadForRequest(Uri.parse(synergiaCookieUrl)));
    await Future.delayed(const Duration(milliseconds: 300));
//#endregion
  }
}
