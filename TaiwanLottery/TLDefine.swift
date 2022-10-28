//
//  TLDefine.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/28.
//

import UIKit

// #if UAT_MODE
let kWebSerViceURL: String = "https://smuat.megatime.com.tw/taiwanlottery/api"
let kWSEncryptEnabled: Bool = true
// #endif
// Home/Station
// taiwanLotteryWebServiePathProtocol
protocol TLWSPathProtocol {
    // return String
    func urlPath() -> String
}

enum TLWSPathHome: String, TLWSPathProtocol {
    case Station
    
    func urlPath() -> String {
        return "\(kWebSerViceURL)/System/\(self.rawValue)"
    }
}

// MARK: - Color
extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static let darkOrangeColor: UIColor = UIColor(named: "darkOrange")! // 0xE6813C
    static let lightOrangeColor: UIColor = UIColor(named: "lightOrange")! // 0xFFBC03

}

// MARK: - Image
extension UIImage {
    // background
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
