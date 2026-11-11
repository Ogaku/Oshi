// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart' as apps;
import 'package:dio/dio.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AppCenter {
  static bool _initializedOnce = false;
  static bool _updateDialogShown = false;

  static String get szkolnyAppKey =>
      Platform.environment['OSHI-APP-TOKEN-D73A3091-2328-4DA3-8632-2D1090A4881A'] ?? 'AZ_SZKOLNY_APP_TOKEN';

  static Future<void> initialize() async {
    if (_initializedOnce || !(isAndroid || isIOS)) return;
    try {
      await apps.AppCenter.start(secret: 'AZ_APPCENTER_TELEMETRY_TOKEN');
      _initializedOnce = true;

      await apps.AppCenter.enable();
      await apps.AppCenterAnalytics.enable();
      await apps.AppCenterCrashes.enable();

      await apps.AppCenterAnalytics.trackEvent(name: '1850951C-DEEC-4D29-A71A-16CBD1BB786B'.localized);
    } catch (ex) {
      // ignored
    }
  }

  /// FOX channel: optional builds published as GitHub pre-releases tagged `fox-<version>`.
  /// `releases/latest` never returns pre-releases, so regular users are never offered these.
  static Future<AppVersion?> fetchFoxVersions() async {
    try {
      var response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Oshi-App',
        },
      )).get('https://api.github.com/repos/Ogaku/Oshi/releases', queryParameters: {'per_page': 30});

      var data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is! List) return null;

      AppVersion? best;
      for (var release in data) {
        if (release is! Map || release['draft'] == true || release['prerelease'] != true) continue;

        final tag = (release['tag_name'] ?? '').toString().trim();
        if (!tag.toLowerCase().startsWith('fox-')) continue;

        Uri? downloadUri;
        if (release['assets'] is List) {
          for (var a in release['assets'] as List) {
            if (a is Map && a['name']?.toString().toLowerCase().endsWith('.apk') == true && a['browser_download_url'] != null) {
              downloadUri = Uri.parse(a['browser_download_url'].toString());
              break;
            }
          }
        }
        if (downloadUri == null) continue;

        final candidate = AppVersion(
          version: Version.parse(tag.substring(4)),
          notes: (release['body'] ?? '').toString(),
          download: downloadUri,
        );
        if (best == null || candidate.version > best.version) best = candidate;
      }
      return best;
    } catch (ex) {
      return null;
    }
  }

  static Future<AppVersion?> fetchVersions() async {
    // FOX builds only ever follow the FOX channel
    if (Share.isFoxChannel) return fetchFoxVersions();

    try {
      // 1. Try GitHub Releases API first
      var response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Oshi-App',
        },
      )).get('https://api.github.com/repos/Ogaku/Oshi/releases/latest');

      var data = response.data;
      if (data is String) data = jsonDecode(data);

      String tagName = (data['tag_name'] ?? '').toString().trim();
      if (tagName.isEmpty) tagName = (data['name'] ?? '').toString().trim();

      Uri? downloadUri;
      if (data['assets'] is List) {
        var assets = data['assets'] as List;
        for (var a in assets) {
          if (a is Map) {
            var name = a['name']?.toString().toLowerCase() ?? '';
            if (isAndroid && name.endsWith('.apk') && a['browser_download_url'] != null) {
              downloadUri = Uri.parse(a['browser_download_url'].toString());
              break;
            } else if (isIOS && name.endsWith('.ipa') && a['browser_download_url'] != null) {
              downloadUri = Uri.parse(a['browser_download_url'].toString());
              break;
            }
          }
        }
      }

      downloadUri ??= Uri.parse(
        isAndroid
            ? 'https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.apk'
            : 'https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.ipa',
      );

      return AppVersion(
        version: Version.parse(tagName),
        notes: (data['body'] ?? '').toString(),
        download: downloadUri,
      );
    } catch (ex) {
      // Fallback to Toudai version_data.json if GitHub API fails
      try {
        var result = (await Dio(BaseOptions(
          baseUrl: 'https://raw.githubusercontent.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )).get('/Ogaku/Toudai/main/version_data.json')).data;

        if (result is String) result = jsonDecode(result);

        return AppVersion(
          version: Version.parse(result['version']?.toString()),
          download: Uri.parse(result[isAndroid ? 'download_apk' : 'download_ios']),
        );
      } catch (e) {
        return null;
      }
    }
  }

  static Future<({bool result, Uri download, AppVersion? version})> checkForUpdates() async {
    try {
      if (kIsWeb) return (result: false, download: Uri(), version: null);

      var remoteAppVersion = await fetchVersions();
      if (remoteAppVersion == null) return (result: false, download: Uri(), version: null);

      var currentVersion = Version.parse(Share.buildNumber);
      bool hasUpdate = remoteAppVersion.version > currentVersion;

      return (result: hasUpdate, download: remoteAppVersion.download, version: remoteAppVersion);
    } catch (ex) {
      return (result: false, download: Uri(), version: null);
    }
  }

  static void showUpdatePrompt(BuildContext context, AppVersion appVersion) {
    if (kIsWeb || _updateDialogShown || !context.mounted) return;
    _updateDialogShown = true;

    final String title = '/BaseApp/Update/AlertHeader'.localized.isNotEmpty &&
            !'/BaseApp/Update/AlertHeader'.localized.startsWith('/')
        ? '/BaseApp/Update/AlertHeader'.localized
        : 'Aktualizacja dostępna';

    final String message =
        'Dostępna jest nowa wersja aplikacji (${appVersion.version}).\nCzy chcesz ją zaktualizować?';

    if (isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Później'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(ctx).pop();
                performUpdate(context, appVersion);
              },
              child: const Text('Aktualizuj'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Później'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                performUpdate(context, appVersion);
              },
              child: const Text('Aktualizuj'),
            ),
          ],
        ),
      );
    }
  }

  /// Returns a human-readable reason why the downloaded [apk] would be rejected by Android,
  /// or null when it looks installable (or when it cannot be inspected).
  static Future<String?> _verifyDownloadedApk(File apk) async {
    try {
      final info = await FlutterAppInstaller().verifyApk(filePath: apk.path);
      if (info['valid'] != true) return null; // can't tell - let Android decide

      if (info['packageMatches'] == false) {
        return 'Pobrany plik to inna aplikacja (${info['packageName']}). Zgłoś problem twórcom.';
      }
      if (info['signatureMatches'] == false) {
        return 'Pobrana wersja jest podpisana innym kluczem niż zainstalowana aplikacja, dlatego Android '
            'odrzuci aktualizację ("Aplikacja nie została zainstalowana").\n\n'
            'Odinstaluj aktualną wersję i zainstaluj nową ręcznie z przeglądarki (dane aplikacji zostaną usunięte).';
      }
      if (info['isNewer'] == false) {
        return 'Pobrana wersja (${info['versionCode']}) nie jest nowsza od zainstalowanej '
            '(${info['installedVersionCode']}), więc Android nie pozwoli jej zainstalować.';
      }
    } catch (_) {
      // ignored - verification is best effort
    }
    return null;
  }

  static Future<void> performUpdate(BuildContext context, AppVersion appVersion) async {
    if (!isAndroid) {
      try {
        await launchUrl(appVersion.download, mode: LaunchMode.externalApplication);
      } catch (ex) {
        // ignored
      }
      return;
    }

    ValueNotifier<double> downloadProgress = ValueNotifier<double>(0.0);
    ValueNotifier<String> statusMessage = ValueNotifier<String>('Przygotowywanie...');
    bool isCancelled = false;
    final CancelToken cancelToken = CancelToken();

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Pobieranie aktualizacji'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: downloadProgress,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(value: value > 0 ? value : null);
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: statusMessage,
                  builder: (context, msg, _) => Text(msg),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  isCancelled = true;
                  cancelToken.cancel('User cancelled download');
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Anuluj'),
              ),
            ],
          ),
        );
      },
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final apkFile = File('${tempDir.path}/Oshi-update.apk');
      if (await apkFile.exists()) {
        try {
          await apkFile.delete();
        } catch (_) {}
      }

      final dio = Dio();
      await dio.downloadUri(
        appVersion.download,
        apkFile.path,
        cancelToken: cancelToken,
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            double prog = received / total;
            downloadProgress.value = prog;
            statusMessage.value =
                '${(prog * 100).toStringAsFixed(0)}% (${(received / (1024 * 1024)).toStringAsFixed(1)} MB / ${(total / (1024 * 1024)).toStringAsFixed(1)} MB)';
          } else {
            statusMessage.value = '${(received / (1024 * 1024)).toStringAsFixed(1)} MB';
          }
        },
      );

      if (isCancelled) return;

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      try {
        await Permission.requestInstallPackages.request();
      } catch (_) {}

      // Android silently answers "App not installed" for a mismatching signature or version,
      // so check the downloaded package ourselves first and explain what is wrong.
      final problem = await _verifyDownloadedApk(apkFile);
      if (problem != null) {
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Nie można zainstalować aktualizacji'),
              content: Text(problem),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await launchUrl(appVersion.download, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                  child: const Text('Otwórz w przeglądarce'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Installed straight from the app cache, served by the FileProvider (cache-path)
      await FlutterAppInstaller().installApk(filePath: apkFile.path);
    } catch (ex) {
      if (isCancelled) return;

      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }

      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Błąd instalacji aktualizacji'),
            content: const Text(
                'Nie udało się automatycznie pobrać lub zainstalować aktualizacji. Czy chcesz otworzyć stronę pobierania w przeglądarce?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await launchUrl(appVersion.download, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                child: const Text('Otwórz w przeglądarce'),
              ),
            ],
          ),
        );
      }
    }
  }
}

class AppVersion {
  AppVersion({required this.version, this.notes = '', required this.download});

  final Version version;
  final String notes;
  final Uri download;
}

class Version {
  Version({this.major = 0, this.minor = 0, this.patch = 0, this.build = 0});

  Version.parse(String? versionString) {
    try {
      if (versionString?.trim().isEmpty ?? true) return;
      String cleaned = versionString!.trim().replaceAll(RegExp(r'^[vV]'), '');
      List<String> parts = cleaned.split(".");

      if (parts.isNotEmpty) major = int.tryParse(RegExp(r'\d+').stringMatch(parts[0]) ?? '') ?? 0;
      if (parts.length > 1) minor = int.tryParse(RegExp(r'\d+').stringMatch(parts[1]) ?? '') ?? 0;
      if (parts.length > 2) patch = int.tryParse(RegExp(r'\d+').stringMatch(parts[2]) ?? '') ?? 0;
      if (parts.length > 3) build = int.tryParse(RegExp(r'\d+').stringMatch(parts[3]) ?? '') ?? 0;
    } catch (ex) {
      // ignored
    }
  }

  int major = 0, minor = 0, patch = 0, build = 0;

  bool operator <(Version other) => _compare(other) < 0;
  bool operator <=(Version other) => _compare(other) <= 0;
  bool operator >(Version other) => _compare(other) > 0;
  bool operator >=(Version other) => _compare(other) >= 0;

  int _compare(Version other) {
    if (major > other.major) return 1;
    if (major < other.major) return -1;

    if (minor > other.minor) return 1;
    if (minor < other.minor) return -1;

    if (patch > other.patch) return 1;
    if (patch < other.patch) return -1;

    if (build > other.build) return 1;
    if (build < other.build) return -1;

    return 0;
  }

  @override
  String toString() => '$major.$minor.$patch.$build';
}
