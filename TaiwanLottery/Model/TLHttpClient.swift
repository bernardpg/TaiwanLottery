//
//  HttpClient.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/17.
//
// 網路訊號問題 沒網路 沒資料  error handling
// 100% loss system timeout
// very bad network packet dropped 
import Foundation
import Alamofire

enum TLNetworkErrorConditions: Int, Error {
    // 300
    case requestTimeOut = -1001 // 100% loss
    case airplaneMode = -1009 // airplane mode
    case noCellularMode = -1020
    case parseResponse = -1017
    
    var type: String {
        switch self {
        case .requestTimeOut: return "AlertInfo:ResponseError"
        case .airplaneMode: return "AlertInfo:NotReachable"
        case .noCellularMode: return "AlertInfo:NotReachable"
        case .parseResponse: return "AlertInfo:ResponseError"
        }
    }
        
    // 400 timeout and no network
    
}

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

class TLHttpClient {
    static let shared = TLHttpClient()
    
    func lotteryAPI<E: Decodable>(
        method: HTTPMethod, _ requested: TLStationRequestDTO,
        url: URL, completion: @escaping(Result<TLResponse<E>, TLNetworkErrorConditions>) -> Void) {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = kBaseHeader
        
        let encoder = JSONEncoder()
        let user = TLStationRequestDTO(lat: requested.lat, lon: requested.lon, distance: requested.distance)
        let data = try? encoder.encode(user)
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  error == nil
            else {
                return completion(.failure(TLNetworkErrorConditions(rawValue: error!.code) ?? .airplaneMode))  }
                do {
                    let decoder = JSONDecoder()
                    let createUserResponse = try decoder.decode(TLResponse<E>.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(createUserResponse))
                    }
                } catch {
                    
                    print(error.localizedDescription)
                }
        }.resume()
    }
}
