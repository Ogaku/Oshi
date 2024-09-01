// ignore_for_file: curly_braces_in_flow_control_structures
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
  @override
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

  @override
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

  @override
  LibrusLogin({SynergiaData? synergiaData, String? login, String? pass, String? proxyUrl})
      : synergiaData = synergiaData ?? SynergiaData(),
        synergiaLogin = login ?? '',
        synergiaPass = pass ?? '',
        proxyUrl = proxyUrl ?? 'http://127.0.0.1:80';

  @override
  Future setupToken({IProgress<({double? progress, String? message})>? progress}) async {
    // Reset the session, regenerate cookies
    synergiaData.session = Dio();
    synergiaData.cookieJar = CookieJar();

    synergiaData.session.interceptors.add(CookieManager(synergiaData.cookieJar));
    progress?.report((progress: 0.3, message: '55E2F1C8-AD9E-4D3B-B700-0DB1493C8B07'.localized));

//#region OAuth Setup
    try {
      // The first step - acquire the OAuth session token
      // We're here foe cookies only - suppress all exceptions
      await synergiaData.session.get(librusOAuthUri,
          options: Options(followRedirects: false),
          queryParameters: {'client_id': 46, 'response_type': 'code', 'scope': 'mydata'});
    } on DioException catch (e) {
      if (kDebugMode) print(e);
    }

    progress?.report((progress: 0.4, message: 'C8C69498-3A64-4560-A275-3ACDCCCF1B90'.localized));

    try {
      // Post the login data for OAuth authorization
      await synergiaData.session.post(librusOAuthUri,
          queryParameters: {'client_id': 46},
          data: FormData.fromMap({'action': 'login', 'login': synergiaLogin, 'pass': synergiaPass}));
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response?.data?['errors']?[0]?['message']?.toString() ?? e.message);
      } else {
        throw Exception(e.message);
      }
    }

    // Acquire all required authorization headers here
    progress?.report((progress: 0.5, message: '9A7C2236-A7DC-4668-81F2-FEF1FF9B0AAE'.localized));
    await synergiaData.session.get(librusOAuthGrantUri, queryParameters: {'client_id': 46});
//#endregion

//#region Gateway
    // Activate the API access - get the user ID
    progress?.report((progress: 0.6, message: '41D4096F-11CA-4385-8191-436DB9BF8A07'.localized));
    var tokenResponse = await synergiaData.session.get(gatewayTokenInfoUri);

    // Activate the API access - authenticate using the ID
    progress?.report((progress: 0.7, message: '5DA166B8-F9B9-40A1-8E90-22ED84E498A3'.localized));
    var authResponse = await synergiaData.session.get(format(gatewayTokenGrantUri, tokenResponse.data['UserIdentifier']));

    // Validate the user still has access to the API
    if (authResponse.data['UserState'] != 'ACTIVE') throw Exception('64D1FFB7-0CF9-43D1-8B74-998F2AB6CAA6'.localized);
//#endregion

//#region Messages
    // Make the first request - used to gain general authorization
    progress?.report((progress: 0.8, message: 'FB716D2D-FFFA-41C5-91B5-02678F6D0FA5'.localized));
    await synergiaData.session.get(messagesActivationUri);

    // Copy all cookies from the authorization session
    progress?.report((progress: 0.9, message: '4D52E8BC-6C25-4C8F-B031-777844C73315'.localized));
    synergiaData.cookieJar.saveFromResponse(
        Uri.parse(messagesCookieUrl), await synergiaData.cookieJar.loadForRequest(Uri.parse(synergiaCookieUrl)));
    await Future.delayed(const Duration(milliseconds: 400));
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
