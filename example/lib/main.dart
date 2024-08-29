import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController urlTextContoller = TextEditingController();

  String phoneOrEmail = '';
  String otp = '';
  bool isInitIos = false;
  bool isDebugLoggingEnabled = false;

  static const String appId = "YOUR_APPID";

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      debugPrint("init headless sdk is called for android");
    }
    _otplessFlutterPlugin.setWebviewInspectable(true);
  }

  Future<void> openLoginPage() async {
    Map<String, dynamic> arg = {'appId': appId};
    _otplessFlutterPlugin.openLoginPage(onHeadlessResult, arg);
  }

  Future<void> startHeadlessWithWhatsapp() async {
    if (Platform.isIOS && !isInitIos) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
      return;
    }
    Map<String, dynamic> arg = {'channelType': "WHATSAPP"};
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  Future<void> startHeadlessForPhoneAndEmail() async {
    if (Platform.isIOS && !isInitIos) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
      return;
    }
    Map<String, dynamic> arg = {};
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

    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  void onHeadlessResult(dynamic result) {
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
    urlTextContoller.dispose();
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
          child:
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Adjusted margin
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Makes the buttons fill the width
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
                          onPressed: startHeadlessWithWhatsapp,
                          child: const Text("Start Headless With WhatsApp"),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSwitch(
                          value: isDebugLoggingEnabled,
                          onChanged: _handleSwitchChange,
                        ),
                        const SizedBox(height: 16),
                        TextField(
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
                        CupertinoButton.filled(
                          onPressed: startHeadlessForPhoneAndEmail,
                          child: const Text("Start with Phone and Email"),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _dataResponse,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )

        ),
      ),
    );
  }

  void _handleSwitchChange(bool value) {
    setState(() {
      isDebugLoggingEnabled = value;
      _otplessFlutterPlugin.enableDebugLogging(isDebugLoggingEnabled);
    });
  }
}
