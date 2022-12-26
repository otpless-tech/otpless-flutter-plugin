//
//  WhatsAppHandler.swift
//  otpless_flutter
//
//  Created by Solai Raj on 08/10/22.
//

import Foundation
import UIKit

public enum responseCodeError: String {
    case urlNotFound = "581"
    case invalidURL = "582"
    case verificationFailed = "583"
}

public class WhatsAppHandler: NSObject {
    
    public static let sharedInstance: WhatsAppHandler = {
        let instance = WhatsAppHandler()
        return instance
    }()
   
    public func initiateWhatsappLogin(scheme : String,result: @escaping FlutterResult) {
        if scheme == "" {
            result("\(responseCodeError.invalidURL.rawValue)-\(StringValues.WHATSAPP_LINK_CREATE_ERROR)")
        }else{
            if let newUrl = scheme.removingPercentEncoding as String? {
            print(newUrl)
            if let urlString = URL(string: newUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if let whatsappURL = NSURL(string: urlString.absoluteString) {
                    if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(whatsappURL as URL)
                        }
                    } else {
                        result("\(responseCodeError.urlNotFound.rawValue)-\(StringValues.WHATSAPP_NOT_FOUND)")
                    }
                }else{
                    result("\(responseCodeError.invalidURL.rawValue)-\(StringValues.WHATSAPP_LINK_CREATE_ERROR)")

                }
            }else{
                result("\(responseCodeError.invalidURL.rawValue)-\(StringValues.WHATSAPP_LINK_CREATE_ERROR)")
            }
            } else {
                result("\(responseCodeError.invalidURL.rawValue)-\(StringValues.WHATSAPP_LINK_CREATE_ERROR)")

            }
        }
    }
    
}
