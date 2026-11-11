import 'flutter_app_installer_platform_interface.dart';

class FlutterAppInstaller {
  Future<String?> get platformVersion {
    return FlutterAppInstallerPlatform.instance.platformVersion;
  }

  Future<String?> get versionName {
    return FlutterAppInstallerPlatform.instance.versionName;
  }

  Future<int?> get versionCode {
    return FlutterAppInstallerPlatform.instance.versionCode;
  }

  Future<bool> get isDeviceRooted {
    return FlutterAppInstallerPlatform.instance.isDeviceRooted;
  }

  Future<bool> get isSystemApplication {
    return FlutterAppInstallerPlatform.instance.isSystemApplication;
  }

  Future<bool> get hasShellRootPermission {
    return FlutterAppInstallerPlatform.instance.hasShellRootPermission;
  }

  Future<bool> installApk({
    required String filePath,
    bool silently = false,
  }) async {
    return FlutterAppInstallerPlatform.instance.installApk(filePath: filePath, silently: silently);
  }
}
