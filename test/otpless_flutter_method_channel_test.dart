import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otpless_flutter/otpless_flutter_method_channel.dart';

void main() {
  MethodChannelOtplessFlutter platform = MethodChannelOtplessFlutter();
  const MethodChannel channel = MethodChannel('otpless_flutter');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
