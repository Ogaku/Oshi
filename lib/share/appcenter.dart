import 'dart:convert';
import 'dart:io';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart' as apps;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:format/format.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:path_provider/path_provider.dart';

class AppCenter {
  static bool _initializedOnce = false;
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

  static Future<AppVersion?> fetchVersions() async {
    try {
      var result =
          (await Dio(BaseOptions(baseUrl: 'https://raw.githubusercontent.com')).get('/Ogaku/Toudai/main/version_data.json'))
              .data;

      if (result is String) result = jsonDecode(result);

      return AppVersion(
          version: Version.parse(result['version']?.toString()),
          download: Uri.parse(result[isAndroid ? 'download_apk' : 'download_ios']));
    } catch (ex) {
      return null;
    }
  }

  static Future<({bool result, Uri download})> checkForUpdates() async {
    try {
      var result = (await fetchVersions())!;
      var checkResult = (result: result.version > Version.parse(Share.buildNumber), download: result.download);
      if (isAndroid &&
          checkResult.result &&
          (await (Connectivity().checkConnectivity())) == ConnectivityResult.wifi) {
        // Else try to download the update and show a notification
        NotificationController.sendNotification(
            title: '05ABEB49-7597-47DB-B200-C9F64799ED5A'.localized.format(result.version),
            content: '7F2D0551-2391-4676-ADED-FAECF0CB89D7'.localized,
            category: NotificationCategories.other,
            id: 9999991);

        var progress = Progress<({double? progress, String? message})>();
        progress.progressChanged.subscribe((args) => NotificationController.sendNotification(
            title: '05ABEB49-7597-47DB-B200-C9F64799ED5A'.localized.format(result.version),
            content: '7F2D0551-2391-4676-ADED-FAECF0CB89D7'.localized,
            category: NotificationCategories.other,
            progress: args?.value.progress ?? 0.0,
            id: 9999991));

        // Download
        var path = '${(await getTemporaryDirectory()).path}/Oshi.apk';
        if (await _download(result.download, path, progress)) {
          await Future.delayed(const Duration(seconds: 3));
          await NotificationController.sendNotification(
              title: '2C4D5FB8-EA44-472A-BF73-1701C8C066D0'.localized,
              content: 'B9F622DB-5DFD-4056-871E-2E7AFD0B982C'.localized.format(result.version),
              data: 'update_android\n$path',
              category: NotificationCategories.other,
              id: 9999991);
        } else {
          await NotificationController.sendNotification(
              title: '25C82C3D-4C3E-44A1-B2CC-F29FC76B79FC'.localized,
              content: '17EE54B1-00DA-4A47-82AD-FF03D11312F9'.localized,
              category: NotificationCategories.other,
              id: 9999991);
        }

        return (result: false, download: Uri());
      } else if ((isIOS || isAndroid) && checkResult.result) {
        NotificationController.sendNotification(
            title: '099A022C-1072-426E-B729-02E99DF75B84'.localized,
            content: '2602BCBF-D632-41A9-81BF-C27B03756DED'.localized.format(result.version),
            category: NotificationCategories.other,
            data: 'url\n${result.download}',
            id: 9999993);

        return (result: false, download: Uri());
      }

      return checkResult;
    } catch (ex) {
      return (result: false, download: Uri());
    }
  }

  static Future<bool> _download(Uri url, String savePath,
      [IProgress<({double? progress, String? message})>? progress]) async {
    try {
      Response response = await Dio().getUri(
        url,
        onReceiveProgress: (r, t) => progress?.report((progress: r / t, message: null)),
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) {
              return status != null ? status < 500 : false;
            }),
      );
      var raf = File(savePath).openSync(mode: FileMode.writeOnly);
      raf.writeFromSync(response.data);
      await raf.close();
      return true;
    } catch (ex) {
      return false;
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
      List<String> parts = versionString!.split(".");

      major = int.parse(parts[0]);
      if (parts.length > 1) {
        minor = int.parse(parts[1]);
        if (parts.length > 2) {
          patch = int.parse(parts[2]);
          if (parts.length > 3) {
            build = int.parse(parts[3]);
          }
        }
      }
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
