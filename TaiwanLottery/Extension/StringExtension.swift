//
//  StringExtension.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/11/2.
//

import Foundation
import UIKit

// 轉多國語系
func LString(_ string: String?) -> String {
    return NSLocalizedString(string ?? "", comment: "")
}
// 如果argument 是 0 -> no parameter
// if != 0 -> +argument
func LStringFormat(_ string: String, _ arguments: CVarArg...) -> String {
    
    if arguments.count == 0 {
        return LString(string)
    }
    let strSentance: String = LString(string)
    let strText = String(format: strSentance, arguments: arguments)
    return strText
}
