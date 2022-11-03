//
//  ErrorExtension.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/11/1.
//

import Foundation
import UIKit

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
