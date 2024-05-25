import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:oshi/providers/librus/librus_login.dart';
import 'package:oshi/providers/librus/librus_reader.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class SynergiaData {
  SynergiaData() : session = Dio() {
    librusApi = LibrusReader(this);
    session.httpClientAdapter = NativeAdapter();
  }

  Dio session;
  CookieJar cookieJar = CookieJar();

  LibrusLogin? synergiaLogin;
  LibrusReader? librusApi;
}
