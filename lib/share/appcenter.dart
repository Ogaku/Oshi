import 'dart:convert';
import 'dart:io';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart' as apps;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/share.dart';
import 'package:path_provider/path_provider.dart';

class AppCenter {
  static Future<void> initialize() async {
    try {
      await apps.AppCenter.start(secret: 'AZ_APPCENTER_TELEMETRY_TOKEN');
      await apps.AppCenter.enable();
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
          download: Uri.parse(result[Platform.isAndroid ? 'download_apk' : 'download_ios']));
    } catch (ex) {
      return null;
    }
  }

  static Future<({bool result, Uri download})> checkForUpdates() async {
    try {
      var result = (await fetchVersions())!;
      var checkResult = (result: result.version > Version.parse(Share.buildNumber), download: result.download);
      if (Platform.isAndroid &&
          checkResult.result &&
          (await (Connectivity().checkConnectivity())) == ConnectivityResult.wifi) {
        // Else try to download the update and show a notification
        NotificationController.sendNotification(
            title: 'Downloading Oshi v${result.version}',
            content: 'Please wait a while...',
            category: NotificationCategories.other,
            id: 9999991);

        var progress = Progress<({double? progress, String? message})>();
        progress.progressChanged.subscribe((args) => NotificationController.sendNotification(
            title: 'Downloading Oshi v${result.version}',
            content: 'Please wait a while...',
            category: NotificationCategories.other,
            progress: args?.value.progress ?? 0.0,
            id: 9999991));

        // Download
        var path = '${(await getTemporaryDirectory()).path}/Oshi.apk';
        if (await _download(result.download, path, progress)) {
          await Future.delayed(const Duration(seconds: 3));
          await NotificationController.sendNotification(
              title: 'The latest Oshi is ready!',
              content: 'Oshi v${result.version} is waiting for you...',
              data: 'update_android\n$path',
              category: NotificationCategories.other,
              id: 9999991);
        } else {
          await NotificationController.sendNotification(
              title: 'Update failed!',
              content: 'An error occurred and Oshi couldn\'t downlaod the latest update...',
              category: NotificationCategories.other,
              id: 9999991);
        }

        return (result: false, download: Uri());
      } else if ((Platform.isIOS || Platform.isAndroid) && checkResult.result) {
        NotificationController.sendNotification(
            title: 'The latest Oshi is waiting for you!',
            content: 'Click to download Oshi v${result.version}',
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
            followRedirects: false,
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
}
