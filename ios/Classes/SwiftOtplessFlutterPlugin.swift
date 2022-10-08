//
//  Strings.swift
//  otpless_flutter
//
//  Created by Solai Raj on 08/10/22.
//

import Flutter
import UIKit


public class SwiftOtplessFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "otpless_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftOtplessFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let args = call.arguments as! Dictionary<String,String>
      if(call.method == "openWhatsapp"){
          WhatsAppHandler.sharedInstance.initiateWhatsappLogin(scheme: args["uri"]!, result: result)
      }else{
          result("iOS " + UIDevice.current.systemVersion)
      }
  }

   
}
