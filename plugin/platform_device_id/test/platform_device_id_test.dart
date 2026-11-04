import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_device_id/platform_device_id.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('com.di1shuai.flutter/platform_device_id');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Get Device ID ', () async {
    String? deviceID = await PlatformDeviceId.getDeviceId;
    expect(deviceID, '42');
  });
}
