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
          Otpless.sharedInstance.headlessDelegate = self;
          let args = call.arguments as! [String: Any]
          let jsonString = args["arg"] as! String
          let data = jsonString.data(using: .utf8)!
          let argument: [String: String] = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
          let headlessRequest = createHeadlessRequest(args: argument)
          if let otp = argument["otp"] {
              Otpless.sharedInstance.verifyOTP(otp: otp, headlessRequest: headlessRequest)
          } else {
              Otpless.sharedInstance.startHeadless(headlessRequest: createHeadlessRequest(args: argument))
          }
      } else if (call.method == "initHeadless") {
          guard let viewController = UIApplication.shared.delegate?.window??.rootViewController else {return}
          let args = call.arguments as! [String: Any]
          let appId = args["arg"] as! String
          Otpless.sharedInstance.initialise(vc: viewController, appId: appId)
      } else if (call.method == "setHeadlessCallback") {
          Otpless.sharedInstance.headlessDelegate = self;
      } else if (call.method == "setWebviewInspectable") {
          let args = call.arguments as! [String: Any]
          var isInspectable = args["arg"] as? Bool
          if isInspectable == nil {
              isInspectable = false
          }
          Otpless.sharedInstance.webviewInspectable = isInspectable!
      } else if (call.method == "enableDebugLogging") {
          let args = call.arguments as? [String: Any]
          let shouldEnableDebugLogging = args?["arg"] as? Bool ?? false
          
          if shouldEnableDebugLogging {
              Otpless.sharedInstance.setLoggerDelegate(delegate: self)
          } 
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

extension SwiftOtplessFlutterPlugin: onHeadlessResponseDelegate {
    public func onHeadlessResponse(response: OtplessSDK.HeadlessResponse?) {
        if response == nil {
            return
        }
        let flutterResponse: [String: Any] = ["statusCode": response!.statusCode,
                                              "responseType": response!.responseType,
                                              "response": response!.responseData]
        let jsonData = try! JSONSerialization.data(withJSONObject: flutterResponse, options: [])
        ChannelManager.shared.invokeMethod(method: "otpless_callback_event", arguments: String(data: jsonData, encoding: .utf8))
    }
}

extension SwiftOtplessFlutterPlugin: OtplessLoggerDelegate {
    public func otplessLog(string: String, type: String) {
        print("Otpless Log of type : \(type)\n\n\(string)")
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

