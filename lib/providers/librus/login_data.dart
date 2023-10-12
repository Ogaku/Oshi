import 'package:ogaku/providers/librus/librus_login.dart';
import 'package:ogaku/providers/librus/librus_reader.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class SynergiaData {
  SynergiaData() {
    librusApi = LibrusReader(this);
  }

  Dio session = Dio();
  CookieJar cookieJar = CookieJar();

  LibrusLogin? synergiaLogin;
  LibrusReader? librusApi;
}
