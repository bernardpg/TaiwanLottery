//
//  LotteoryModel.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/17.
//

import Foundation

struct TLStationRequestDTO: Encodable {
    let lat: Double
    let lon: Double
    let distance: Double

}

struct TLResponse<E: Decodable>: Decodable {
    let code: Int
    let msg: String
    var content: E?
    
    private enum CodingKeys: String, CodingKey {
        case code = "rtCode"
        case msg = "rtMsg"
        case content
    }
    
    init(rtCode: Int, rtMsg: String, content: E) {
        self.code = rtCode
        self.msg = rtMsg
        self.content = content
    }
}

struct TLLotteryStores: Decodable {
    var list: [TLLotteryInfo]
}

struct TLLotteryInfo: Decodable {
    let name: String
    let address: String
    let distance: Double
    let lat: Double
    let lon: Double
}

struct TLLocation: Decodable {
    var lat: Double
    var lon: Double
}
