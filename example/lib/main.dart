import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  String _userToken = 'Unknown';
  final _otplessFlutterPlugin = Otpless();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // ** Function that is called when page is loaded
  // ** We can check the auth state in this function 
  Future<void> initPlatformState() async {
    _otplessFlutterPlugin.authStream.listen((token) {
      // TODO: Handle user token like making api calls
      setState(() {
        _userToken = token ?? "Unknown";
      });
    });
  }

  // ** Function to initiate the login process
  void initiateWhatsappLogin(String intentUrl) async{
    var result = await _otplessFlutterPlugin.loginUsingWhatsapp(intentUrl: intentUrl);
    if(result != null){
      // TODO: Handle errors here like showing toasts
      print(result);
    }
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
                      child: Text("Login With Whatsapp"),
                      onPressed: () {
                        initiateWhatsappLogin("whatsapp://send?phone=918882921758&text=\u200E\u200E\u200B\u200C\u200B\u200B\u200B\u200B\u200B\u200C\u200D\u200C\u200B\u200D\u200CHi%20WhatsApp!%0APlease%20verify%20my%20number%20with%20Android%20Example%20App.");
                      }),
                  Text(_userToken)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
