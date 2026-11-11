# Writing Dart Register Extensions for Oshi

Oshi executes provider extensions at runtime using the [`d4rt`](https://pub.dev/packages/d4rt) Dart interpreter (the same architecture used by Mangayomi). Because extensions are plain `.dart` files interpreted in a sandboxed Dart VM, they work across **Android, iOS, Desktop, and Web** without violating AOT or iOS App Store code-signing rules.

## Structure of an Extension

Every extension imports `package:oshi/bridge_lib.dart`, defines a class extending `OProvider`, and exposes a top-level `main(OSource source)` entrypoint returning an instance of that class:

```dart
// @id PROVGUID-CUSTOM-MY-REGISTER
// @name My School Register
// @version 1.0.0
// @lang en
// @author YourName
// @icon https://example.com/icon.png
// @baseUrl https://api.example.com
// @description Log in with a My School Register account.

import 'dart:convert';
import 'package:oshi/bridge_lib.dart';

class MyRegisterExtension extends OProvider {
  MyRegisterExtension({required this.source});

  final OSource source;
  final OHttpClient _http = OHttpClient();
  Map<String, dynamic> _data = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
    reportProgress(0.2, 'Signing in...');
    final res = await _http.post(
      '${source.baseUrl}/login',
      body: jsonEncode({
        'username': credentials['login'],
        'password': credentials['pass'],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      return {'success': false, 'message': 'Invalid credentials (${res.statusCode})'};
    }
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> refresh(String? weekStartIso) async {
    reportProgress(0.5, 'Fetching grades and timetable...');
    final res = await _http.get('${source.baseUrl}/student/summary');
    if (res.statusCode == 200 && res.json is Map) {
      _data = (res.json as Map).cast<String, dynamic>();
      setRegisterDataJson(_data);
      return {'success': true};
    }
    return {'success': false, 'message': 'Failed to refresh'};
  }

  @override
  Future<Map<String, dynamic>> refreshMessages() async => {'success': true};

  @override
  Future<Map<String, dynamic>> sendMessage(
    List<Map<String, dynamic>> receivers,
    String topic,
    String content,
  ) async =>
      {'success': true};

  @override
  Future<Map<String, dynamic>> fetchMessageContent(Map<String, dynamic> parent, bool byMe) async =>
      {'success': true, 'result': parent};

  @override
  Future<Map<String, dynamic>> moveMessageToTrash(Map<String, dynamic> parent, bool byMe) async =>
      {'success': true};

  @override
  Future<Map<String, dynamic>> markEventAsViewed(Map<String, dynamic> parent) async => {'success': true};

  @override
  Future<Map<String, dynamic>> markEventAsDone(Map<String, dynamic> parent) async => {'success': true};

  @override
  Future<Map<String, dynamic>> markAnnouncementAsViewed(Map<String, dynamic> parent) async => {'success': true};

  @override
  Map<String, dynamic> getRegisterDataJson() => _data;
}

MyRegisterExtension main(OSource source) {
  return MyRegisterExtension(source: source);
}
```

## Available Host Bridge APIs (`package:oshi/bridge_lib.dart`)

- **`OSource`**: Metadata passed to `main(OSource source)` (`id`, `name`, `description`, `version`, `lang`, `baseUrl`, `iconUrl`, `bannerUrl`, `loginType`).
- **`OHttpClient`**: Cookie-aware HTTP client (`get`, `post`, `put`, `delete`, `setHeader`, `clearCookies`) returning `OHttpResponse` (`statusCode`, `body`, `json`, `headers`).
- **`OProtocolDriver`**: High-speed native protocol accelerator (`OProtocolDriver('librus')`, `OProtocolDriver('vulcan')`, `OProtocolDriver('sample')`).
- **Top-level helpers**:
  - `reportProgress(double? progress, String? message)`
  - `setRegisterDataJson(Map<String, dynamic> providerDataJson)`
  - `localized(String key)`
  - `generateHebeKeyPair()` & `getHebeSignatureHeaders(...)`
  - `uuidV4()`, `sha256Hex(String input)`, `md5Hex(String input)`

