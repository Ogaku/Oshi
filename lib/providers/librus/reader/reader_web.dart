// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:dio/browser.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:format/format.dart';
import 'package:oshi/models/progress.dart';
import 'package:universal_io/io.dart';
import '../constants.dart';

import 'package:dio/dio.dart';
import 'package:oshi/providers/librus/reader/librus_reader.dart' as reader;

class SynergiaData extends reader.SynergiaData {
  @override
  SynergiaData([this.proxyUrl = 'http://127.0.0.1:80']) : session = DioForBrowser() {
    librusApi = LibrusReader(this);
    session.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
  }

  @override
  Map<String, String> cookies = {};

  @override
  DioForBrowser session;
  final String proxyUrl;
}

class LibrusReader extends reader.LibrusReader {
  @override
  final SynergiaData synergiaData;

  @override
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
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$synergiaCookieUrl/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$synergiaCookieUrl/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data;
    }
  }

  @override
  Future<Map<String, dynamic>> messagesRequest(String endpoint) async {
    try {
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
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
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
                'method': "GET",
                'cookies': synergiaData.cookies
              })))
          .data['data'] as Map<String, dynamic>;
    }
  }

  @override
  Future messagesDelete(String endpoint) async {
    try {
      await synergiaData.session.post(synergiaData.proxyUrl,
          data: jsonEncode({
            'uri':
                '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
            'method': "DELETE",
            'cookies': synergiaData.cookies
          }));
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      await synergiaData.synergiaLogin!.setupToken(); // Re-authorize
      await synergiaData.session.post(synergiaData.proxyUrl,
          data: jsonEncode({
            'uri':
                '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
            'method': "DELETE",
            'cookies': synergiaData.cookies
          }));
    }
  }

  @override
  Future<Map<String, dynamic>> messagesPost(String endpoint, Object data) async {
    try {
      return (await synergiaData.session.post(synergiaData.proxyUrl,
              data: jsonEncode({
                'uri':
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
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
                    '$messagesApiBaseUri/${endpoint.replaceAll('https://api.librus.pl', 'https://synergia.librus.pl/gateway/api')}',
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

  @override
  LibrusLogin({SynergiaData? synergiaData, String? login, String? pass, String? proxyUrl})
      : synergiaData = synergiaData ?? SynergiaData(proxyUrl ?? 'http://127.0.0.1:80'),
        synergiaLogin = login ?? '',
        synergiaPass = pass ?? '',
        proxyUrl = proxyUrl ?? 'http://127.0.0.1:80';

  @override
  Future setupToken({IProgress<({double? progress, String? message})>? progress}) async {
    // Reset the session, regenerate cookies
    synergiaData.session = DioForBrowser();
    synergiaData.cookies = {};

    if (kIsWeb) {
      synergiaData.session.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
    }

    //synergiaData.session.interceptors.add(WebCookieManager(synergiaData.cookieJar)); // TODO
    progress?.report((progress: 0.3, message: "API'ing the Librus OAuth API..."));

//#region OAuth Setup
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

    progress?.report((progress: 0.4, message: "Bruteforcing your damn password..."));

    try {
      // Post the login data for OAuth authorization
      await synergiaData.session.post(proxyUrl,
          data: jsonEncode({
            'uri': librusOAuthUri,
            'method': "POST",
            'query': {'client_id': 46},
            'data': {'action': 'login', 'login': synergiaLogin, 'pass': synergiaPass},
            'cookies': synergiaData.cookies
          }));
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response?.data?['errors']?[0]?['message']?.toString() ?? e.message);
      } else {
        throw Exception(e.message);
      }
    }

    // Acquire all required authorization headers here
    progress?.report((progress: 0.5, message: "Grating the global access..."));
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
    progress?.report((progress: 0.6, message: "Salvaging the access tokens..."));
    try {
      var tokenResponse = await synergiaData.session
          .post(proxyUrl, data: jsonEncode({'uri': gatewayTokenInfoUri, 'method': "GET", 'cookies': synergiaData.cookies}));

      // Activate the API access - authenticate using the ID
      progress?.report((progress: 0.7, message: "Tokenizing all the tokens..."));
      var authResponse = await synergiaData.session.post(proxyUrl,
          data: jsonEncode({
            'uri': format(gatewayTokenGrantUri, tokenResponse.data['data']['UserIdentifier']),
            'method': "GET",
            'cookies': synergiaData.cookies
          }));

      // Validate the user still has access to the API
      if (authResponse.data['data']['UserState'] != 'ACTIVE') throw Exception('User session not active!');
//#endregion
    } on DioException catch (e) {
      if (kDebugMode) print(e);
    }
//#region Messages
    // Make the first request - used to gain general authorization
    progress?.report((progress: 0.8, message: "Messaging the messages module..."));
    await synergiaData.session
        .post(proxyUrl, data: jsonEncode({'uri': messagesActivationUri, 'method': "GET", 'cookies': synergiaData.cookies}));

    // Copy all cookies from the authorization session
    progress?.report((progress: 0.9, message: "Sharing the cookies with others..."));
    //synergiaData.cookieJar.saveFromResponse(
    //    Uri.parse(messagesCookieUrl), await synergiaData.cookieJar.loadForRequest(Uri.parse(synergiaCookieUrl)));
//#endregion

    // Sample API responses for partial testing
    // var syngeriaResponse = await synergiaData.session.get('https://synergia.librus.pl/gateway/api/2.0/Me');
    // var messagesResponse = await synergiaData.session.get('https://wiadomosci.librus.pl/api/me');
  }
}

extension on Future<Response<dynamic>> {
  Future<Response<dynamic>> setCookies(Map<String, String> cookies) => then((value) {
        cookies.addAll((value.data['cookies'] as Map<String, dynamic>).cast());
        return value;
      });
}
