import 'package:flutter_test/flutter_test.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:otpless_flutter/otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter/otpless_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOtplessFlutterPlatform 
    with MockPlatformInterfaceMixin
    implements OtplessFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OtplessFlutterPlatform initialPlatform = OtplessFlutterPlatform.instance;

  test('$MethodChannelOtplessFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOtplessFlutter>());
  });

  test('getPlatformVersion', () async {
    Otpless otplessFlutterPlugin = Otpless();
    MockOtplessFlutterPlatform fakePlatform = MockOtplessFlutterPlatform();
    OtplessFlutterPlatform.instance = fakePlatform;
  
    expect(await otplessFlutterPlugin.getPlatformVersion(), '42');
  });
}
