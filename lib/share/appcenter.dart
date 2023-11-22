import 'dart:io';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart' as apps;
import 'package:dio/dio.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';

class AppCenter {
  static Future<void> initialize() async {
    await apps.AppCenter.start(secret: 'fab7ea1dd329834407310d51379f5af7c99d19da');
    await apps.AppCenter.enable();
  }

  static Future<AppVersion?> fetchVersions() async {
    try {
      var result = (await Dio(BaseOptions(baseUrl: 'https://api.appcenter.ms', headers: {'X-API-Token': 'APPXTOKEN'}))
              .get('/v0.1/sdk/apps/APPSECRET/releases/latest'))
          .data;

      return AppVersion(
          version: Version.parse(result['short_version']),
          notes: result['release_notes'],
          download: Uri.parse(Platform.isAndroid
              ? result['download_url']
              : 'https://github.com/Ogaku/Oshi/releases/latest/download/Oshi.ipa'));
    } catch (ex) {
      return null;
    }
  }

  static Future<({bool result, Uri download})> checkForUpdates() async {
    try {
      var result = (await fetchVersions())!;
      var ret = (result: result.version > Version.parse(Share.buildNumber), download: result.download);
      if (Platform.isAndroid) {
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
      } else if (Platform.isIOS) {
        NotificationController.sendNotification(
            title: 'The latest Oshi is waiting for you!',
            content: 'Click to download Oshi v${result.version}',
            category: NotificationCategories.other,
            data: 'url\n${result.download}',
            id: 9999993);

        return (result: false, download: Uri());
      }

      return ret;
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
  AppVersion({required this.version, required this.notes, required this.download});

  final Version version;
  final String notes;
  final Uri download;
}
