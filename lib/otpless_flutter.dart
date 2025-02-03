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

  Future<void> setHeadlessCallback(OtplessResultCallback callback) async {
    _otplessChannel.setHeadlessCallback(callback);
  }

  Future<void> setWebviewInspectable(bool isInspectable) async {
    _otplessChannel.setWebviewInspectable(isInspectable);
  }

  Future<void> enableDebugLogging(bool isDebugLoggingEnabled) async {
    _otplessChannel.enableDebugLogging(isDebugLoggingEnabled);
  }

  Future<Map<String, String>> showPhoneHint(bool showFallback) async {
    final result = await _otplessChannel.showPhoneHintLib(showFallback);
    return result;
  }

  Future<void> attachSecureService(String appId) async {
    return await _otplessChannel.attachSecureService(appId);
  }
  
  Future<List<Map<String, dynamic>>> getEjectedSimEntries() async {
    return await _otplessChannel.getEjectedSimEntries();
  }

  Future<void> setSimEventListener(final OtplessSimEventListener? listener) async {
    return await _otplessChannel.setSimEventListener(listener);
  }

  Future<void> commitHeadlessResponse(final dynamic response) async {
    return await _otplessChannel.commitHeadlessResponse(response);
  }
}
