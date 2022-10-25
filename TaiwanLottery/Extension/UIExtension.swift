//
//  UIExtension.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/25.
//

import Foundation
import MapKit
// extention //HTTpClient

extension UIApplication {
    func openURL(_ string: String) {
        guard let url = URL(string: string) else {
            return
        }
        open(url)
    }
}
