//
//  Strings.swift
//  otpless_flutter
//
//  Created by Solai Raj on 08/10/22.
//

import Flutter
import UIKit
import OtplessSDK


public class SwiftOtplessFlutterPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "otpless_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftOtplessFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      ChannelManager.shared.setMethodChannel(channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if(call.method == "isWhatsAppInstalled"){
          result(Otpless.sharedInstance.isWhatsappInstalled())
      }
      else if(call.method == "openOtplessLoginPage"){
          guard let viewController = UIApplication.shared.delegate?.window??.rootViewController else {return}
          Otpless.sharedInstance.delegate = self;
          let args = call.arguments as! [String: Any]
          let jsonString = args["arg"] as! String
          let argument: [String: Any] = SwiftOtplessFlutterPlugin.convertToDictionary(text: jsonString)!
          let appId: String = argument["appId"] as! String
          let params: [String: Any]? = argument["params"] as? [String: Any]
          Otpless.sharedInstance.showOtplessLoginPageWithParams(appId: appId, vc: viewController, params: params)
      } else if (call.method == "setLoaderVisibility") {
          // do nothing
      } else if (call.method == "startHeadless") {
          guard let viewController = UIApplication.shared.delegate?.window??.rootViewController else {return}
          Otpless.sharedInstance.delegate = self;
          let args = call.arguments as! [String: Any]
          let jsonString = args["arg"] as! String
          let data = jsonString.data(using: .utf8)!
          let argument: [String: String] = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
          let appId: String = argument["appId"]!
          Otpless.sharedInstance.initialise(vc: viewController, appId: appId)
          Otpless.sharedInstance.startHeadless(headlessRequest: createHeadlessRequest(args: argument))
      }
  }
  
    private func createHeadlessRequest(args: [String: String]) -> HeadlessRequest {
        let headlessRequest = HeadlessRequest()
        if let phone = args["phone"] {
            let countryCode: String = args["countryCode"]!
            headlessRequest.setPhoneNumber(number: phone, withCountryCode: countryCode)
        } else if let email = args["email"] {
            headlessRequest.setEmail(email)
        } else if let channelType = args["channelType"] {
            headlessRequest.setChannelType(channelType)
        }
        if let otp = args["otp"] {
//            headlessRequest.setOtp(otp: otp)
        }
        return headlessRequest
    }
    
    static func filterParamsCondition(_ call: FlutterMethodCall, on onHaving: ([String: Any]) -> Void, off onNotHaving: () -> Void) {
        if let args = call.arguments as? [String: Any] {
            if let jsonString = args["arg"] as? String {
                if let params = convertToDictionary(text: jsonString) {
                    onHaving(params)
                    return
                }
            }
        }
        onNotHaving()
    }

  static  func convertToJsonString(response: OtplessSDK.OtplessResponse?) -> String? {
        do {
            var params = [String: Any]()
            if (response != nil && response?.errorString != nil){
                params["errorMessage"] = response?.errorString
            } else {
                if response != nil && response?.responseData != nil {
                    params =  response!.responseData!
                }
            }
            if response != nil {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            } else {
                return"{}"
            }
        } catch {
            print("Error converting to JSON string: \(error)")
            return"{}"
        }
        
        return "{}"
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

   
}

extension SwiftOtplessFlutterPlugin: onResponseDelegate{
    public func onResponse(response: OtplessSDK.OtplessResponse?) {
        ChannelManager.shared.invokeMethod(method: "otpless_callback_event", arguments: SwiftOtplessFlutterPlugin.convertToJsonString(response: response))
    }
}

class ChannelManager {
    static let shared = ChannelManager()

    private var methodChannel: FlutterMethodChannel?

    private init() {}

    func setMethodChannel(_ channel: FlutterMethodChannel) {
        methodChannel = channel
    }

    func invokeMethod(method: String, arguments: Any?) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
}

