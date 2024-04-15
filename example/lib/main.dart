import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _otplessFlutterPlugin.initHeadless("YOUR_APPID");
    _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
  }

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function

  Future<void> openLoginPage() async {
    Map<String, dynamic> arg = {'appId': "YOUR_APPID"};
    _otplessFlutterPlugin.openLoginPage((result) {
      var message = "";
      if (result['data'] != null) {
        final token = result['data']['token'];
        message = "token: $token";
      }
      setState(() {
        _dataResponse = message ?? "Unknown";
      });
    }, arg);
  }

  Future<void> startHeadlessWithWhatsapp() async {
    Map<String, dynamic> arg = {'channelType': "WHATSAPP"};
    _otplessFlutterPlugin.startHeadless((result) {
      setState(() {
        _dataResponse = jsonEncode(result);
      });
    }, arg);
  }

  Future<void> startHeadlessForPhoneAndEmail() async {
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
}
