//
//  LotteoryModel.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/17.
//

import Foundation

struct CreateRequestBody: Encodable {
    let lat: Double
    let lon: Double
    let distance: Double

}

struct CreateUserResponse: Decodable {
    let rtCode: Int
    let rtMsg: String
    let content: LotteryStores
}

struct LotteryStores: Decodable {
    var list: [LotteryInfo]
}

struct LotteryInfo: Decodable {
    let name: String
    let address: String
    let distance: Double
    let lat: Double
    let lon: Double
}

struct Location: Decodable {
    var lat: Double
    var lon: Double
}
