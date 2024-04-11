import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'otpless_flutter_platform_interface.dart';

typedef OtplessResultCallback = void Function(dynamic);

/// An implementation of [OtplessFlutterPlatform] that uses method channels.
class MethodChannelOtplessFlutter extends OtplessFlutterPlatform {
  final eventChannel = const EventChannel('otpless_callback_event');

  @visibleForTesting
  final methodChannel = const MethodChannel('otpless_flutter');

  OtplessResultCallback? _callback;

  MethodChannelOtplessFlutter() {
    _setEventChannel();
  }

  void _setEventChannel() {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "otpless_callback_event") {
        final json = call.arguments as String;
        final result = jsonDecode(json);
        _callback!(result);
      }
    });
  }

  Future<void> openOtplessLoginPage(
      OtplessResultCallback callback, Map<String, dynamic> jsonObject) async {
    _callback = callback;
    await methodChannel
        .invokeMethod("openOtplessLoginPage", {'arg': json.encode(jsonObject)});
  }

  Future<bool> isWhatsAppInstalled() async {
    final isInstalled = await methodChannel.invokeMethod("isWhatsAppInstalled");
    return isInstalled as bool;
  }

  Future<void> setLoaderVisibility(bool visibility) async {
    await methodChannel
        .invokeMethod("setLoaderVisibility", {'arg': visibility});
  }

  Future<void> startHeadless(
      OtplessResultCallback callback, Map<String, dynamic> jsonObject) async {
    _callback = callback;
    await methodChannel
        .invokeMethod("startHeadless", {'arg': json.encode(jsonObject)});
  }

  Future<void> initHeadless(String appid) async {
    await methodChannel.invokeMethod("initHeadless", {'arg': appid});
  }

  Future<void> enableOneTap(bool isEnable) async {
    await methodChannel.invokeMethod("enableOneTap", {'arg': isEnable});
  }

  Future<void> setHeadlessCallback(OtplessResultCallback callback) async {
    _callback = callback;
    await methodChannel.invokeMethod("setHeadlessCallback");
  }
}
