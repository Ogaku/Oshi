import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oshi/extensions/extension_manager.dart';
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/extensions/runtime/dart_extension_provider.dart';
import 'package:oshi/share/share.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Share.translator.loadResources('en');
  });

  test('Extension repository index.json parses and matches script SHA-256 digests', () async {
    final indexFile = File('extensions_repo/index.json');
    expect(indexFile.existsSync(), isTrue);

    final decoded = jsonDecode(await indexFile.readAsString()) as List<dynamic>;
    final manifests = decoded
        .whereType<Map<String, dynamic>>()
        .map(ExtensionManifest.fromJson)
        .toList();

    expect(manifests.length, 3);
    expect(
      manifests.map((m) => m.id).toSet(),
      equals({
        'PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA',
        'PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI',
        'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER',
      }),
    );

    final paths = {
      'PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA': 'extensions_repo/dart/librus/librus.dart',
      'PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI': 'extensions_repo/dart/vulcan/vulcan.dart',
      'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER': 'extensions_repo/dart/sample/sample.dart',
    };

    for (final manifest in manifests) {
      final scriptFile = File(paths[manifest.id]!);
      expect(scriptFile.existsSync(), isTrue);
      final source = await scriptFile.readAsString();
      final actualRawSha = sha256.convert(utf8.encode(source)).toString().toLowerCase();
      final actualLfSha = sha256.convert(utf8.encode(source.replaceAll('\r\n', '\n'))).toString().toLowerCase();
      expect(
        {actualRawSha, actualLfSha},
        contains(manifest.sha256?.toLowerCase()),
      );
    }
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

  test('d4rt executes librus.dart, vulcan.dart, and sample.dart and runs Sample provider end-to-end', () async {
    final indexJson = jsonDecode(await File('extensions_repo/index.json').readAsString()) as List<dynamic>;
    final manifests = {
      for (final item in indexJson.whereType<Map<String, dynamic>>())
        item['id'] as String: ExtensionManifest.fromJson(item),
    };

    // Validate Librus and Vulcan d4rt scripts compile and instantiate OProvider via main(source)
    final librusSource = await File('extensions_repo/dart/librus/librus.dart').readAsString();
    final librusProvider = DartExtensionProvider(
      manifest: manifests['PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA']!.copyWith(sourceCode: librusSource),
    );
    expect(librusProvider.providerName, equals('Librus Synergia'));
    expect(librusProvider.loginType, equals(2));

    final vulcanSource = await File('extensions_repo/dart/vulcan/vulcan.dart').readAsString();
    final vulcanProvider = DartExtensionProvider(
      manifest: manifests['PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI']!.copyWith(sourceCode: vulcanSource),
    );
    expect(vulcanProvider.providerName, equals('eduVULCAN / UONET+'));
    expect(vulcanProvider.loginType, equals(20));

    // Execute Sample provider login & refresh through d4rt
    final sampleSource = await File('extensions_repo/dart/sample/sample.dart').readAsString();
    final sampleProvider = DartExtensionProvider(
      manifest: manifests['PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER']!.copyWith(sourceCode: sampleSource),
    );

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
