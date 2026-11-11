import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_app_installer_platform_interface.dart';

/// An implementation of [FlutterAppInstallerPlatform] that uses method channels.
class MethodChannelFlutterAppInstaller extends FlutterAppInstallerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_app_installer');

  @override
  Future<String?> get platformVersion async {
    return await methodChannel.invokeMethod('getPlatformVersion');
  }

  /// Retrieve Android Version Name
  @override
  Future<String?> get versionName async {
    return await methodChannel.invokeMethod('getVersionName');
  }

  /// Retrieve Android Version Code
  @override
  Future<int?> get versionCode async {
    return await methodChannel.invokeMethod('getVersionCode');
  }

  /// Check if the device is rooted, return a bool.
  @override
  Future<bool> get isDeviceRooted async {
    return await methodChannel.invokeMethod('isDeviceRooted');
  }

  /// Check if the application is system application, return a bool.
  @override
  Future<bool> get isSystemApplication async {
    return await methodChannel.invokeMethod('isSystemApplication');
  }

  /// Check if the application has shell root permission, return a bool.
  @override
  Future<bool> get hasShellRootPermission async {
    return await methodChannel.invokeMethod('checkShellRootPermission');
  }

  /// Install the apk in the [filePath].
  /// If you want to install the apk [silently], the device need to be system application or has root permission on your emulator.
  ////// After the installation is finished will return a bool.
  @override
  Future<bool> installApk({
    required String filePath,
    bool silently = false,
  }) async {
    return await methodChannel.invokeMethod(
      "installApk",
      <String, dynamic>{
        "filePath": filePath,
        "silently": silently,
      },
    );
  }
}
