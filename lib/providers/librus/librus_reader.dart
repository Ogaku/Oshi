// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'constants.dart';

import 'package:dio/dio.dart';
import 'package:ogaku/providers/librus/login_data.dart';

class LibrusReader {
  final SynergiaData synergiaData;

  LibrusReader(this.synergiaData);

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
