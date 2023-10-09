import 'package:shared_preferences/shared_preferences.dart';
import 'package:szkolny/providers/librus/librus_login.dart';
import 'package:szkolny/providers/librus/librus_reader.dart';
import 'package:uuid/uuid.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class SynergiaData {
  SynergiaData([this.settingsSessionId]) {
    loginData = SyngergiaLoginData(settingsSessionId);
    librusApi = LibrusReader(this);
  }

  String? settingsSessionId;
  Dio session = Dio();
  CookieJar cookieJar = CookieJar();

  SyngergiaLoginData? loginData;
  LibrusLogin? synergiaLogin;
  LibrusReader? librusApi;
}

class SyngergiaLoginData {
//#region Settings
  String login = '';
  String pass = '';
//#endregion

  String? settingsSessionId;
  SharedPreferences? sharedPreferences;

  SyngergiaLoginData([this.settingsSessionId]);

  Future<SharedPreferences> preferences() async {
    settingsSessionId ??= const Uuid().v4();
    sharedPreferences ??= await SharedPreferences.getInstance();
    return sharedPreferences!;
  }

  Future<bool> exists() async {
    await load(); // Load the saved settings
    return login.isNotEmpty && pass.isNotEmpty;
  }

  Future load() async {
    login = await getSetting('login');
    pass = await getSetting('pass');
  }

  Future save() async {
    await setSetting('login', login);
    await setSetting('pass', pass);
  }

//#region Internal management
  Future<String> getSetting(String key, [String? fallback]) async {
    return (await preferences()).getString('$settingsSessionId+$key') ?? fallback ?? '';
  }

  Future setSetting(String key, String value) async {
    return (await preferences()).setString('$settingsSessionId+$key', value);
  }
//#endregion}
}
