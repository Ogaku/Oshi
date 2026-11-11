// ignore_for_file: deprecated_member_use
import 'package:flutter/services.dart';
import 'package:flutter_app_installer/flutter_app_installer_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MethodChannelFlutterAppInstaller platform = MethodChannelFlutterAppInstaller();
  const MethodChannel channel = MethodChannel('flutter_app_installer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.platformVersion, '42');
  });
}
