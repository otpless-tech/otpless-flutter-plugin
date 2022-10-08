import 'package:appcheck/appcheck.dart';
import 'package:uni_links/uni_links.dart';

import 'otpless_flutter_platform_interface.dart';
import 'package:otpless_flutter/otpless_flutter_method_channel.dart';

class Otpless {
  Future<String?> getPlatformVersion() {
    return OtplessFlutterPlatform.instance.getPlatformVersion();
  }

  /*
    Function to redirect to Whatsapp application
  */
  Future<Map<String, String>> loginUsingWhatsapp(
      {required String intentUrl}) async {
    if (intentUrl.isEmpty) {
      throw Exception({
        "code": "EMPTY_URI",
        "message": "OTPLess Error : Empty intent URI Provided"
      });
    }
    String? res =
        await MethodChannelOtplessFlutter().openWhatsappBot(intentUrl);
    if (res != null) {
      var temp = res.split("-");
      return {"code": temp.first, "message": temp.last};
    }
    return {"code": "NA", "message": "NA"};
  }

  /*
    Getter variable to get stream of authentication tokens if there is
    any logins via whatsapp

    Subscribe / listen to this stream to get user authentication token
  */
  Stream<String?> get authStream {
    return uriLinkStream
        .map((event) => event?.queryParameters['token'] ?? "NA");
  }
}
