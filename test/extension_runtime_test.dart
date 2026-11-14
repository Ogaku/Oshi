import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oshi/extensions/bridge/oshi_bridge.dart';
import 'package:oshi/extensions/bridge/rsa_signer.dart';
import 'package:oshi/extensions/extension_manager.dart';
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/extensions/runtime/dart_extension_provider.dart';
import 'package:oshi/share/share.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Share.translator.loadResources('en');
  });

  test('Bundled extension index.json parses and matches sample.dart SHA-256 digest', () async {
    final indexFile = File('assets/resources/extensions/index.json');
    expect(indexFile.existsSync(), isTrue);

    final decoded = jsonDecode(await indexFile.readAsString()) as List<dynamic>;
    final manifests = decoded
        .whereType<Map<String, dynamic>>()
        .map(ExtensionManifest.fromJson)
        .toList();

    expect(manifests.length, 1);
    expect(manifests.first.id, equals('PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER'));

    final scriptFile = File('assets/resources/extensions/sample.dart');
    expect(scriptFile.existsSync(), isTrue);
    final source = await scriptFile.readAsString();
    final actualRawSha = sha256.convert(utf8.encode(source)).toString().toLowerCase();
    final actualLfSha = sha256.convert(utf8.encode(source.replaceAll('\r\n', '\n'))).toString().toLowerCase();
    expect(
      {actualRawSha, actualLfSha},
      contains(manifests.first.sha256?.toLowerCase()),
    );
  });

  test('normalizeRepoInput handles GitHub URLs, raw URLs, and oshi:// deep links', () {
    expect(
      ExtensionManager.instance.normalizeRepoInput('https://github.com/Ogaku/Oshi-Extensions').url,
      equals('https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json'),
    );
    expect(
      ExtensionManager.instance.normalizeRepoInput('https://github.com/user/repo/tree/dev').url,
      equals('https://raw.githubusercontent.com/user/repo/dev/index.json'),
    );
    expect(
      ExtensionManager.instance
          .normalizeRepoInput('oshi://add-repo?url=https%3A%2F%2Fgithub.com%2FOgaku%2FOshi-Extensions')
          .url,
      equals('https://raw.githubusercontent.com/Ogaku/Oshi-Extensions/main/index.json'),
    );
  });

  test('OHttpClient normalizes pathless cookies, preserves redirect cookies, and isolates host-only domains',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    final seenCookieHeaders = <String, String>{};

    server.listen((HttpRequest req) async {
      seenCookieHeaders['${req.headers.value('host')}${req.uri.path}'] =
          req.headers.value(HttpHeaders.cookieHeader) ?? '';

      if (req.uri.path == '/loguj') {
        req.response.statusCode = 200;
        req.response.headers.add(HttpHeaders.setCookieHeader, 'DZIENNIKSID=abc123; HttpOnly');
        req.response.write('ok');
      } else if (req.uri.path == '/uczen/index') {
        req.response.statusCode = 200;
        req.response.write(req.headers.value(HttpHeaders.cookieHeader) ?? '');
      } else if (req.uri.path == '/hop1') {
        req.response.statusCode = 302;
        req.response.headers.add(HttpHeaders.setCookieHeader, 'HOSTONLY=secret1; Path=/');
        req.response.headers.set(HttpHeaders.locationHeader, 'http://localhost:$port/hop2');
      } else if (req.uri.path == '/hop2') {
        req.response.statusCode = 302;
        req.response.headers.set(HttpHeaders.locationHeader, '/final');
      } else if (req.uri.path == '/final') {
        req.response.statusCode = 200;
        req.response.write('done:${req.headers.value(HttpHeaders.cookieHeader) ?? ''}');
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });

    final prevOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    try {
      final client = OHttpClient();

      // Pathless cookie set on /loguj must be normalized to / and sent to /uczen/index
      final loginRes = await client.get('http://127.0.0.1:$port/loguj');
      expect(loginRes.statusCode, 200);
      final uczenRes = await client.get('http://127.0.0.1:$port/uczen/index');
      expect(uczenRes.body, contains('DZIENNIKSID=abc123'));

      // Manual redirect inspection
      final manualHop = await client.get('http://127.0.0.1:$port/hop1', followRedirects: false);
      expect(manualHop.statusCode, 302);
      expect(manualHop.location, equals('http://localhost:$port/hop2'));

      // 127.0.0.1 received HOSTONLY=secret1, but redirect to localhost must NOT send 127.0.0.1 cookies
      final followRes = await client.get('http://127.0.0.1:$port/hop1', followRedirects: true);
      expect(followRes.statusCode, 200);
      expect(followRes.url, equals('http://localhost:$port/final'));
      expect(seenCookieHeaders['localhost:$port/hop2'], isEmpty);
      expect(client.getCookies('http://127.0.0.1:$port/')['HOSTONLY'], equals('secret1'));
      expect(client.getCookies('http://localhost:$port/').containsKey('HOSTONLY'), isFalse);
    } finally {
      HttpOverrides.global = prevOverrides;
      await server.close(force: true);
    }
  });

  test('RsaHttpSigner generates keypairs and signs canonical request paths', () {
    final kp = RsaHttpSigner.generateKeyPair();
    expect(kp.certificate, isNotEmpty);
    expect(kp.fingerprint.length, equals(32));
    expect(jsonDecode(kp.privateKey), isA<Map<String, dynamic>>());

    final headers = RsaHttpSigner.getSignatureHeaders(
      keyId: kp.fingerprint,
      privateKeyJson: kp.privateKey,
      body: '{"test":1}',
      requestPath: 'https://example.org/tenant/api/mobile/school/lucky?day=2026-11-14',
      canonicalPattern: r'(api/mobile/.+)',
    );
    expect(headers['vCanonicalUrl'], contains('api%2fmobile%2fschool%2flucky'));
    expect(headers['Digest'], startsWith('SHA-256='));
    expect(headers['Signature'], contains('keyId="${kp.fingerprint}"'));
    expect(RsaHttpSigner.sha256DigestBytes('abc').length, equals(32));
  });

  test('OExtensionHostContext merges partial student, timetables, and messages slices', () {
    final ctx = OExtensionHostContext();
    ctx.setRegisterDataFromMap({
      'student': {
        'account': {'id': 1, 'userId': 1, 'number': 5, 'firstName': 'Jan', 'lastName': 'Kowalski'},
      },
      'timetables': {
        'timetable': <String, dynamic>{},
      },
    });
    expect(ctx.lastData?.student.account.firstName, equals('Jan'));

    ctx.setRegisterDataFromMap({
      'messages': {
        'received': [
          {'id': 42, 'topic': 'Hello', 'preview': 'Body'},
        ],
        'sent': <dynamic>[],
        'receivers': <dynamic>[],
      },
    });
    // Student slice must remain intact when updating messages only
    expect(ctx.lastData?.student.account.firstName, equals('Jan'));
    expect(ctx.lastData?.messages.received.length, equals(1));
    expect(ctx.lastData?.messages.received.first.topic, equals('Hello'));
  });

  test('d4rt executes sample.dart and runs Sample provider end-to-end', () async {
    final indexJson = jsonDecode(await File('assets/resources/extensions/index.json').readAsString()) as List<dynamic>;
    final manifest = ExtensionManifest.fromJson(indexJson.first as Map<String, dynamic>);

    final sampleSource = await File('assets/resources/extensions/sample.dart').readAsString();
    final sampleProvider = DartExtensionProvider(
      manifest: manifest.copyWith(sourceCode: sampleSource),
    );
    expect(sampleProvider.loginType, equals(20));

    final loginResult = await sampleProvider.login(credentials: {});
    expect(loginResult.success, isTrue);

    final refreshResult = await sampleProvider.refresh();
    expect(refreshResult.success, isTrue);
    expect(sampleProvider.registerData?.student.account.firstName, equals('Pomura'));
    expect(sampleProvider.registerData?.student.subjects, isNotEmpty);

    final messagesResult = await sampleProvider.refreshMessages();
    expect(messagesResult.success, isTrue);
    expect(sampleProvider.registerData?.messages.received, isNotEmpty);
  });
}
