import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_app_installer_method_channel.dart';

abstract class FlutterAppInstallerPlatform extends PlatformInterface {
  /// Constructs a FlutterAppInstallerPlatform.
  FlutterAppInstallerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAppInstallerPlatform _instance = MethodChannelFlutterAppInstaller();

  /// The default instance of [FlutterAppInstallerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAppInstaller].
  static FlutterAppInstallerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAppInstallerPlatform] when
  /// they register themselves.
  static set instance(FlutterAppInstallerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> get platformVersion {
    throw UnimplementedError('platformVersion has not been implemented.');
  }

  Future<String?> get versionName {
    throw UnimplementedError('versionName has not been implemented.');
  }

  Future<int?> get versionCode {
    throw UnimplementedError('versionCode has not been implemented.');
  }

  Future<bool> get isDeviceRooted {
    throw UnimplementedError('isDeviceRooted has not been implemented.');
  }

  Future<bool> get isSystemApplication {
    throw UnimplementedError('isSystemApplication has not been implemented.');
  }

  Future<bool> get hasShellRootPermission {
    throw UnimplementedError('hasShellRootPermission has not been implemented.');
  }

  Future<bool> installApk({
    required String filePath,
    bool silently = false,
  }) async {
    throw UnimplementedError('installApk() has not been implemented.');
  }
}
