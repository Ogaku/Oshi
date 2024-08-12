import 'package:dio/browser.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/providers/librus/reader/librus_reader.dart' as reader;

class SynergiaData extends reader.SynergiaData {
  SynergiaData([String pvReserved = '']) : session = DioForBrowser() {
    throw Exception("Stub implementation");
  }

  @override
  Map<String, String> cookies = {};

  @override
  DioForBrowser session;
}

class LibrusReader extends reader.LibrusReader {
  @override
  final SynergiaData synergiaData;

  @override
  LibrusReader(this.synergiaData) {
    throw Exception("Stub implementation");
  }

  @override
  Future<Map<String, dynamic>> request(String endpoint) async {
    throw Exception("Stub implementation");
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, Object data) async {
    throw Exception("Stub implementation");
  }

  @override
  Future<String> synergiaRequest(String endpoint) async {
    throw Exception("Stub implementation");
  }

  @override
  Future<Map<String, dynamic>> messagesRequest(String endpoint) async {
    throw Exception("Stub implementation");
  }

  @override
  Future messagesDelete(String endpoint) async {
    throw Exception("Stub implementation");
  }

  @override
  Future<Map<String, dynamic>> messagesPost(String endpoint, Object data) async {
    throw Exception("Stub implementation");
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
        proxyUrl = proxyUrl ?? 'http://127.0.0.1:80' {
    throw Exception("Stub implementation");
  }

  @override
  Future setupToken({IProgress<({double? progress, String? message})>? progress}) async {
    throw Exception("Stub implementation");
  }
}
