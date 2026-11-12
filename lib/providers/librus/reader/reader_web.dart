// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:dio/browser.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:format/format.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/translator.dart';
import 'package:universal_io/io.dart';
import '../constants.dart';

import 'package:dio/dio.dart';
import 'package:oshi/providers/librus/reader/librus_reader.dart' as reader;

String resolveWebProxyUrl(String? raw) {
  final trimmed = (raw ?? '').trim();
  if (trimmed.isEmpty) return 'http://127.0.0.1:5000';
  final lower = trimmed.toLowerCase();
  if (lower.contains('librus.pl') || lower.contains('eduvulcan.pl') || lower.contains('vulcan.net.pl')) {
    return 'http://127.0.0.1:5000';
  }
  return trimmed;
}

class SynergiaData extends reader.SynergiaData {
  SynergiaData([String proxyUrl = 'http://127.0.0.1:5000'])
      : proxyUrl = resolveWebProxyUrl(proxyUrl),
        session = DioForBrowser() {
    librusApi = LibrusReader(this);
    session.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: false);
  }

  @override
  Map<String, String> cookies = {};
  Map<String, String> messagesCookies = {};

  @override
  DioForBrowser session;
  final String proxyUrl;
}

class LibrusReader extends reader.LibrusReader {
  @override
  final SynergiaData synergiaData;

  LibrusReader(this.synergiaData);

  @override
  Future<Map<String, dynamic>> request(String endpoint) async {
    try {
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data['data'] as Map<String, dynamic>;
    }
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, Object data) async {
    try {
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "POST",
                'headers': {
                  HttpHeaders.contentTypeHeader: "application/json",
                },
                'cookies': synergiaData.cookies,
                'data': data
              })))
          .data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$gatewayApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "POST",
                'headers': {
                  HttpHeaders.contentTypeHeader: "application/json",
                },
                'cookies': synergiaData.cookies,
                'data': data
              })))
          .data['data'] as Map<String, dynamic>;
    }
  }

  @override
  Future<String> synergiaRequest(String endpoint) async {
    try {
      final resData = (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$synergiaCookieUrl/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data;
      return (resData is Map ? (resData['data'] is Map ? resData['data']['text'] : resData['data']) : resData)?.toString() ??
          '';
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      final resData = (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$synergiaCookieUrl/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data;
      return (resData is Map ? (resData['data'] is Map ? resData['data']['text'] : resData['data']) : resData)?.toString() ??
          '';
    }
  }

  @override
  Future<Map<String, dynamic>> messagesRequest(String endpoint) async {
    final msgCookies = synergiaData.messagesCookies.isNotEmpty ? synergiaData.messagesCookies : synergiaData.cookies;
    try {
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': msgCookies
              })))
          .data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      final retryCookies = synergiaData.messagesCookies.isNotEmpty ? synergiaData.messagesCookies : synergiaData.cookies;
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': retryCookies
              })))
          .data['data'] as Map<String, dynamic>;
    }
  }

  @override
  Future messagesDelete(String endpoint) async {
    final msgCookies = synergiaData.messagesCookies.isNotEmpty ? synergiaData.messagesCookies : synergiaData.cookies;
    try {
      await synergiaData.session.post(synergiaData.proxyUrl,
          data: jsonEncode({
            'uri':
                '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
            'method': "DELETE",
            'cookies': msgCookies
          }));
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      final retryCookies = synergiaData.messagesCookies.isNotEmpty ? synergiaData.messagesCookies : synergiaData.cookies;
      await synergiaData.session.post(synergiaData.proxyUrl,
          data: jsonEncode({
            'uri':
                '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
            'method': "DELETE",
            'cookies': retryCookies
          }));
    }
  }

  @override
  Future<Map<String, dynamic>> messagesPost(String endpoint, Object data) async {
    final msgCookies = synergiaData.messagesCookies.isNotEmpty ? synergiaData.messagesCookies : synergiaData.cookies;
    try {
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "POST",
                'headers': {
                  HttpHeaders.contentTypeHeader: "application/json",
                },
                'cookies': msgCookies,
                'data': data
              })))
          .data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      final retryCookies = synergiaData.messagesCookies.isNotEmpty ? synergiaData.messagesCookies : synergiaData.cookies;
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "POST",
                'headers': {
                  HttpHeaders.contentTypeHeader: "application/json",
                },
                'cookies': retryCookies,
                'data': data
              })))
          .data['data'] as Map<String, dynamic>;
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
      : synergiaData = synergiaData ?? SynergiaData(resolveWebProxyUrl(proxyUrl)),
        synergiaLogin = login ?? '',
        synergiaPass = pass ?? '',
        proxyUrl = resolveWebProxyUrl(proxyUrl);

  @override
  Future setupToken({IProgress<({double? progress, String? message})>? progress}) async {
    // Reset the session, regenerate cookies
    synergiaData.session = DioForBrowser();
    synergiaData.cookies = {};
    synergiaData.messagesCookies = {};

    if (kIsWeb) {
      synergiaData.session.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: false);
    }

    //synergiaData.session.interceptors.add(WebCookieManager(synergiaData.cookieJar));
    progress?.report((progress: 0.3, message: '55E2F1C8-AD9E-4D3B-B700-0DB1493C8B07'.localized));

//#region OAuth Setup
    try {
      // Establish portalRodzina session
      await synergiaData.session
          .post(proxyUrl,
              data: jsonEncode({
                'uri': librusPortalRodzinaUri,
                'method': "GET",
                'headers': {'Referer': 'https://portal.librus.pl/'},
                'cookies': synergiaData.cookies,
              }))
          .setCookies(synergiaData.cookies);
    } catch (_) {}

    try {
      // The first step - acquire the OAuth session token
      // We're here foe cookies only - suppress all exceptions
      await synergiaData.session
          .post(proxyUrl,
              data: jsonEncode({
                'uri': librusOAuthUri,
                'method': "GET",
                'query': {'client_id': 46, 'response_type': "code", 'scope': "mydata"}
              }))
          .setCookies(synergiaData.cookies);
    } on DioException catch (e) {
      if (kDebugMode) print(e);
    }

    progress?.report((progress: 0.4, message: 'C8C69498-3A64-4560-A275-3ACDCCCF1B90'.localized));

    try {
      // Post the login data for OAuth authorization
      await synergiaData.session
          .post(proxyUrl,
              data: jsonEncode({
                'uri': librusOAuthUri,
                'method': "POST",
                'query': {'client_id': 46},
                'headers': {
                  'X-Requested-With': 'XMLHttpRequest',
                  'Accept': 'application/json, text/javascript, */*; q=0.01',
                  'Origin': 'https://api.librus.pl',
                  'Referer': 'https://api.librus.pl/OAuth/Authorization?client_id=46',
                },
                'data': {'action': 'login', 'login': synergiaLogin, 'pass': synergiaPass},
                'cookies': synergiaData.cookies
              }))
          .setCookies(synergiaData.cookies);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final errData = e.response?.data;
        final msg = errData?['data']?['errors']?[0]?['message']?.toString() ??
            errData?['errors']?[0]?['message']?.toString() ??
            errData?['error']?.toString() ??
            e.message;
        throw Exception(msg);
      } else {
        throw Exception(e.message);
      }
    }

    // Acquire all required authorization headers here
    progress?.report((progress: 0.5, message: '9A7C2236-A7DC-4668-81F2-FEF1FF9B0AAE'.localized));
    await synergiaData.session
        .post(proxyUrl,
            data: jsonEncode({
              'uri': librusOAuthGrantUri,
              'method': "GET",
              'query': {'client_id': 46},
              'cookies': synergiaData.cookies
            }))
        .setCookies(synergiaData.cookies);
//#endregion

//#region Gateway
    // Activate the API access - get the user ID
    progress?.report((progress: 0.6, message: '41D4096F-11CA-4385-8191-436DB9BF8A07'.localized));
    var tokenResponse = await synergiaData.session
        .post(proxyUrl, data: jsonEncode({'uri': gatewayTokenInfoUri, 'method': "GET", 'cookies': synergiaData.cookies}))
        .setCookies(synergiaData.cookies);

    final userIdentifier = tokenResponse.data is Map ? (tokenResponse.data['data']?['UserIdentifier']) : null;
    if (userIdentifier == null) {
      throw Exception('64D1FFB7-0CF9-43D1-8B74-998F2AB6CAA6'.localized);
    }

    // Activate the API access - authenticate using the ID
    progress?.report((progress: 0.7, message: '5DA166B8-F9B9-40A1-8E90-22ED84E498A3'.localized));
    var authResponse = await synergiaData.session
        .post(proxyUrl,
            data: jsonEncode({
              'uri': format(gatewayTokenGrantUri, userIdentifier),
              'method': "GET",
              'cookies': synergiaData.cookies
            }))
        .setCookies(synergiaData.cookies);

    // Validate the user still has access to the API
    if (authResponse.data is! Map || authResponse.data['data']?['UserState'] != 'ACTIVE')
      throw Exception('64D1FFB7-0CF9-43D1-8B74-998F2AB6CAA6'.localized);
//#endregion

//#region Messages
    // Make the first request - used to gain general authorization
    progress?.report((progress: 0.8, message: 'FB716D2D-FFFA-41C5-91B5-02678F6D0FA5'.localized));
    synergiaData.messagesCookies = Map<String, String>.from(synergiaData.cookies);
    try {
      await synergiaData.session
          .post(proxyUrl,
              data: jsonEncode({'uri': messagesActivationUri, 'method': "GET", 'cookies': synergiaData.cookies}))
          .setCookies(synergiaData.messagesCookies);
    } catch (e) {
      if (kDebugMode) print(e);
    }

    // Copy all cookies from the authorization session
    progress?.report((progress: 0.9, message: '4D52E8BC-6C25-4C8F-B031-777844C73315'.localized));
    //synergiaData.cookieJar.saveFromResponse(
    //    Uri.parse(messagesCookieUrl), await synergiaData.cookieJar.loadForRequest(Uri.parse(synergiaCookieUrl)));
    await Future.delayed(const Duration(milliseconds: 400));
//#endregion

    // Sample API responses for partial testing
    // var syngeriaResponse = await synergiaData.session.get('https://synergia.librus.pl/gateway/api/2.0/Me');
    // var messagesResponse = await synergiaData.session.get('https://wiadomosci.librus.pl/api/me');
  }
}

extension on Future<Response<dynamic>> {
  Future<Response<dynamic>> setCookies(Map<String, String> cookies) => then((value) {
        if (value.data is Map && value.data['cookies'] is Map) {
          cookies.addAll((value.data['cookies'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())));
        }
        return value;
      });
}
