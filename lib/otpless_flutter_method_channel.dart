import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'otpless_flutter_platform_interface.dart';
import 'dart:convert';

typedef void OtplessResultCallback(dynamic);

/// An implementation of [OtplessFlutterPlatform] that uses method channels.
class MethodChannelOtplessFlutter extends OtplessFlutterPlatform {
  final eventChannel = EventChannel('otpless_callback_event');

  @visibleForTesting
  final methodChannel = const MethodChannel('otpless_flutter');

  OtplessResultCallback? _callback = null;

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

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> openWhatsappBot(String intentUrl) async {
    var out = await methodChannel
        .invokeMethod<String>('openWhatsapp', {"uri": intentUrl});
    return out;
  }

  Future<void> openOtpless(OtplessResultCallback callback) async {
    _callback = callback;
    await methodChannel.invokeMethod("openOtplessSdk");
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
