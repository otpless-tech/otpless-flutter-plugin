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

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function

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
    // Clean up the controller when the widget is disposed.
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  CupertinoButton.filled(
                      child: Text("Open Otpless Login Page"),
                      onPressed: openLoginPage),
                  CupertinoButton.filled(
                      child: Text("Toggle Loader Visibility"),
                      onPressed: changeLoaderVisibility),
                  CupertinoButton.filled(
                      child: Text("Start Headless With Whatsapp"),
                      onPressed: startHeadlessWithWhatsapp),
                  CupertinoSwitch(value: isDebugLoggingEnabled, onChanged: _handleSwitchChange),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        phoneOrEmail = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Phone or email here',
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your otp here',
                    ),
                  ),
                  CupertinoButton.filled(
                      child: Text("Start with Phone and Email"),
                      onPressed: startHeadlessForPhoneAndEmail),
                  Text(""),
                  SizedBox(height: 100),
                  SizedBox(height: 10),
                  Text(_dataResponse)
                ],
              ),
            ),
          ),
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
