//
//  TLDefine.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/28.
//
// web service 字串 // 色碼

import UIKit
import Foundation
// request
// #if UAT_MODE
let kWebSerViceURL: String = "https://smuat.megatime.com.tw/taiwanlottery/api"
let kWSEncryptEnabled: Bool = true
// #endif

// MARK: - URL Path Webservice

// taiwanLotteryWebServiePathProtocol
protocol TLWSPathProtocol {
    func urlPath() -> String
}

enum TLWSPathHome: String, TLWSPathProtocol {
    case Station
    
    func urlPath() -> String {
        return "\(kWebSerViceURL)/Home/\(self.rawValue)"
    }
}

let kBaseHeader: [String: String] = [ "Encrypt": "0",
    "Content-Type": "application/json"
]

let kAppleMaps =  "https://maps.apple.com/?saddr=Current Location&daddr=%f,%f&z=10&t=s"

// MARK: - Color
extension UIColor {

    static let darkOrangeColor: UIColor = UIColor(named: "darkOrange")! // 0xE6813C
    static let lightOrangeColor: UIColor = UIColor(named: "lightOrange")! // 0xFFBC03
}

// MARK: - Image
extension UIImage {
    // background
    // cal 方法 
    class var iconDirection: UIImage {
        return UIImage(named: "iconDirection")!
    }
    class var mapPinOff: UIImage {
        return UIImage(named: "mapPinOff")!
    }
    class var mapPinOn: UIImage {
        return UIImage(named: "mapPinOn")!
    }
    class var switchModeListMode: UIImage {
        return UIImage(named: "switchModeListMode")!
    }
    class var switchModeMapMode: UIImage {
        return UIImage(named: "switchModeMapMode")!
    }
}

// MARK: - UIFont
extension UIFont {
    static let pinFangTC: UIFont = UIFont(name: "PingFang TC", size: 12)!
}

// MARK: - NotificationCenter
extension Notification.Name {
    static let notifyChangeDistance: Notification.Name = Notification.Name("changeDistance")
}
