import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:otpless_flutter/otpless_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _dataResponse = 'Unknown';
  final _otplessFlutterPlugin = Otpless();
  var loaderVisibility = true;
  bool isSimStateListenerAttached = false;
  final TextEditingController phoneOrEmailTextController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String channel = "WHATSAPP";

  String phoneOrEmail = '';
  String otp = '';
  bool isInitIos = false;

  String deliveryChannel = '';
  String otpLength = "";
  String expiry = "";

  static const String appId = "K8K415KI2VMZV27648JJ" /* "YOUR_APPID" */;

  @override
  void initState() {
    super.initState();
    _otplessFlutterPlugin.enableDebugLogging(true);
    if (Platform.isAndroid) {
      _otplessFlutterPlugin.initHeadless(appId, timeout: 23);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      debugPrint("init headless sdk is called for android");
      attachSecureService();
    }
    _otplessFlutterPlugin.setWebviewInspectable(true);
  }

  Future<void> attachSecureService() async {
    try {
      await _otplessFlutterPlugin.attachSecureService(appId);
    } on PlatformException catch (e) {
      print(
          'PlatformException: ${e.message}, code: ${e.code}, details: ${e.details}');
    }
  }

  Future<void> getEjectedSimStatus() async {
    List<Map<String, dynamic>> data =
        await _otplessFlutterPlugin.getEjectedSimEntries();
    setState(() {
      _dataResponse = data.toString();
    });
  }

  Future<void> openLoginPage() async {
    Map<String, dynamic> arg = {'appId': appId};
    _otplessFlutterPlugin.openLoginPage(onLoginPageResult, arg);
  }

  Future<void> startHeadlessWithChannel() async {
    if (Platform.isIOS && !isInitIos) {
      _otplessFlutterPlugin.initHeadless(appId, timeout: 26);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
      return;
    }
    Map<String, dynamic> arg = {'channelType': channel};
    arg["timeout"] = "21";
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  Future<void> startHeadlessForPhoneAndEmail() async {
    if (Platform.isIOS && !isInitIos) {
      _otplessFlutterPlugin.initHeadless(appId, timeout: 1);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
      return;
    }
    Map<String, dynamic> arg = {};
    arg["timeout"] = "21";
    var x = double.tryParse(phoneOrEmail);
    if (x != null) {
      arg["phone"] = phoneOrEmail;
      arg["countryCode"] = "91";
    } else {
      arg["email"] = phoneOrEmail;
    }

    if (otp.isNotEmpty) {
      arg["otp"] = otp;
    }
    // adding delivery channel, otp length and expiry
    if (deliveryChannel.isNotEmpty) {
      arg["deliveryChannel"] = deliveryChannel;
    }
    if (otpLength.isNotEmpty) {
      arg["otpLength"] = otpLength;
    }
    if (expiry.isNotEmpty) {
      arg["expiry"] = expiry;
    }

    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  Future<void> onSimCheckboxChange(bool isChecked) async {
    if (isChecked) {
      _otplessFlutterPlugin.setSimEventListener((data) {
        setState(() {
          _dataResponse = data.toString();
        });
      });
    } else {
      _otplessFlutterPlugin.setSimEventListener(null);
    }
  }

  void onHeadlessResult(dynamic result) {
    setState(() {
      _dataResponse = jsonEncode(result);
      _otplessFlutterPlugin.commitHeadlessResponse(result);
      String responseType = result["responseType"];
      if (responseType == "OTP_AUTO_READ") {
        String _otp = result["response"]["otp"];
        otpController.text = _otp;
        otp = _otp;
      }
    });
  }

  void onLoginPageResult(dynamic result) {
    setState(() {
      _dataResponse = jsonEncode(result);
    });
  }

  Future<void> changeLoaderVisibility() async {
    loaderVisibility = !loaderVisibility;
    _otplessFlutterPlugin.setLoaderVisibility(loaderVisibility);
  }

  @override
  void dispose() {
    phoneOrEmailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OTPless Flutter Plugin example app'),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Adjusted margin
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Makes the buttons fill the width
                children: [
                  CupertinoButton.filled(
                    onPressed: openLoginPage,
                    child: const Text("Open Otpless Login Page"),
                  ),
                  const SizedBox(height: 16), // Spacing between buttons
                  CupertinoButton.filled(
                    onPressed: changeLoaderVisibility,
                    child: const Text("Toggle Loader Visibility"),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    onPressed: startHeadlessWithChannel,
                    child: const Text("Start Headless With Channel"),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                      onPressed: handlePhoneHint,
                      child: const Text("Show Phone Hint")),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                      onPressed: getEjectedSimStatus,
                      child: const Text("Sim Eject Status")),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: isSimStateListenerAttached,
                          onChanged: (bool? value) {
                            onSimCheckboxChange(value ?? false);
                            setState(() {
                              isSimStateListenerAttached = value!;
                            });
                          },
                        ),
                        Text(
                          isSimStateListenerAttached
                              ? 'Remove Sim Change Listener'
                              : 'Attach Sim Change Listener',
                          style: TextStyle(fontSize: 20),
                        ),
                      ]),
                  TextField(
                    controller: phoneOrEmailTextController,
                    onChanged: (value) {
                      setState(() {
                        phoneOrEmail = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter Phone or email here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    onChanged: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter your OTP here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        channel = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter channel',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    onPressed: startHeadlessForPhoneAndEmail,
                    child: const Text("Start with Phone and Email"),
                  ),
                  const SizedBox(height: 16),
                  // adding delivery channel
                  TextField(
                    onChanged: (value) {
                      deliveryChannel = value;
                    },
                    decoration: const InputDecoration(
                        hintText: "Enter Delivery Channel"),
                  ),
                  const SizedBox(height: 16),
                  // adding otp length
                  TextField(
                    onChanged: (value) {
                      otpLength = value;
                    },
                    decoration:
                        const InputDecoration(hintText: "Enter the OTP length"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // adding expiry
                  TextField(
                    onChanged: (value) {
                      expiry = value;
                    },
                    decoration: const InputDecoration(
                        hintText: "Enter the expiry in seconds"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // response view
                  Text(
                    _dataResponse,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  void handlePhoneHint() async {
    final result = await _otplessFlutterPlugin.showPhoneHint(true);
    setState(() {
      if (result["phoneNumber"] != null) {
        String phone = result["phoneNumber"]!;
        if (phone.length > 10) {
          phone = phone.substring(phone.length - 10);
        }
        phoneOrEmail = phone;
        phoneOrEmailTextController.text = phoneOrEmail;
      } else {
        _dataResponse = result["error"]!;
      }
    });
  }
}
