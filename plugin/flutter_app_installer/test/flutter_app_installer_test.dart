import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:flutter_app_installer/flutter_app_installer_method_channel.dart';
import 'package:flutter_app_installer/flutter_app_installer_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAppInstallerPlatform with MockPlatformInterfaceMixin implements FlutterAppInstallerPlatform {
  @override
  Future<String?> get platformVersion => Future.value('42');

  @override
  // TODO: implement hasShellRootPermission
  Future<bool> get hasShellRootPermission => throw UnimplementedError();

  @override
  Future<bool> installApk({required String filePath, bool silently = false}) {
    // TODO: implement installApk
    throw UnimplementedError();
  }

  @override
  // TODO: implement isDeviceRooted
  Future<bool> get isDeviceRooted => throw UnimplementedError();

  @override
  // TODO: implement isSystemApplication
  Future<bool> get isSystemApplication => throw UnimplementedError();

  @override
  // TODO: implement versionCode
  Future<int?> get versionCode => throw UnimplementedError();

  @override
  // TODO: implement versionName
  Future<String?> get versionName => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> verifyApk({required String filePath}) => throw UnimplementedError();
}

void main() {
  final FlutterAppInstallerPlatform initialPlatform = FlutterAppInstallerPlatform.instance;

  test('$MethodChannelFlutterAppInstaller is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAppInstaller>());
  });

  test('getPlatformVersion', () async {
    FlutterAppInstaller flutterAppInstallerPlugin = FlutterAppInstaller();
    MockFlutterAppInstallerPlatform fakePlatform = MockFlutterAppInstallerPlatform();
    FlutterAppInstallerPlatform.instance = fakePlatform;

    expect(flutterAppInstallerPlugin.platformVersion, '42');
  });
}
