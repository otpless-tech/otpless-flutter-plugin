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

  Future<void> openOtpless(
      OtplessResultCallback callback, Map<String, dynamic>? jsonObject) async {
    _callback = callback;
    if (jsonObject == null) {
      await methodChannel.invokeMethod("openOtplessSdk");
    } else {
      await methodChannel
          .invokeMethod("openOtplessSdk", {'arg': json.encode(jsonObject)});
    }
  }

  Future<void> openOtplessLoginPage(
      OtplessResultCallback callback, Map<String, dynamic>? jsonObject) async {
    _callback = callback;
    if (jsonObject == null) {
      await methodChannel.invokeMethod("openOtplessLoginPage");
    } else {
      await methodChannel.invokeMethod(
          "openOtplessLoginPage", {'arg': json.encode(jsonObject)});
    }
  }

  Future<void> signInCompleted() async {
    await methodChannel.invokeMethod("onSignComplete");
  }

  Future<void> hideFabButton() async {
    await methodChannel.invokeMethod("hideFabButton");
  }

  Future<bool> isWhatsAppInstalled() async {
    final isInstalled = await methodChannel.invokeMethod("isWhatsAppInstalled");
    return isInstalled as bool;
  }
}
