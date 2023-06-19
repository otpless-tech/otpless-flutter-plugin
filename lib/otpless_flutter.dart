import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter/otpless_flutter_method_channel.dart';

class Otpless {
  final MethodChannelOtplessFlutter _otplessChannel =
      MethodChannelOtplessFlutter();

  Future<String?> getPlatformVersion() {
    return OtplessFlutterPlatform.instance.getPlatformVersion();
  }

  /*
    Function to redirect to Whatsapp application
  */
  Future<void> start(OtplessResultCallback callback,
      {Map<String, dynamic>? jsonObject}) async {
    _otplessChannel.openOtpless(callback, jsonObject);
  }

  Future<void> signInCompleted() async {
    _otplessChannel.signInCompleted();
  }

  Future<void> hideFabButton() async {
    _otplessChannel.hideFabButton();
  }

  Future<bool> isWhatsAppInstalled() async {
    return _otplessChannel.isWhatsAppInstalled();
  }
}
