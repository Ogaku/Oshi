import 'package:oshi/models/progress.dart';
import 'package:dio/dio.dart';

abstract class SynergiaData {
  Map<String, String> get cookies;
  Dio get session;

  LibrusLogin? synergiaLogin;
  LibrusReader? librusApi;
}

abstract class LibrusReader {
  SynergiaData get synergiaData;
  
  Future<Map<String, dynamic>> request(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Object data);
  Future<String> synergiaRequest(String endpoint);
  Future<Map<String, dynamic>> messagesRequest(String endpoint);
  Future messagesDelete(String endpoint) async {}
  Future<Map<String, dynamic>> messagesPost(String endpoint, Object data);
}

abstract class LibrusLogin {
  String get proxyUrl;
  String get synergiaLogin;
  String get synergiaPass;
  SynergiaData get synergiaData;

  Future setupToken({IProgress<({double? progress, String? message})>? progress}) async {}
}
