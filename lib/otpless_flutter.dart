import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter/otpless_flutter_method_channel.dart';

class Otpless {
  final MethodChannelOtplessFlutter _otplessChannel =
      MethodChannelOtplessFlutter();

  Future<String?> getPlatformVersion() {
    return OtplessFlutterPlatform.instance.getPlatformVersion();
  }

  /*
    open login page
  */
  Future<void> openLoginPage(
      OtplessResultCallback callback, Map<String, dynamic> jsonObject) async {
    _otplessChannel.openOtplessLoginPage(callback, jsonObject);
  }

  Future<bool> isWhatsAppInstalled() async {
    return _otplessChannel.isWhatsAppInstalled();
  }

  Future<void> setLoaderVisibility(bool visibility) async {
    return _otplessChannel.setLoaderVisibility(visibility);
  }

  /*
    start headless
  */
  Future<void> startHeadless(
      OtplessResultCallback callback, Map<String, dynamic> jsonObject) async {
    _otplessChannel.startHeadless(callback, jsonObject);
  }

  Future<void> initHeadless(String appid) async {
    _otplessChannel.initHeadless(appid);
  }

  Future<void> enableOneTap(bool isEnable) async {
    _otplessChannel.enableOneTap(isEnable);
  }

  Future<void> setHeadlessCallback(OtplessResultCallback callback) async {
    _otplessChannel.setHeadlessCallback(callback);
  }
}
