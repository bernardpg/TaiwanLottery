//
//  HttpClient.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/17.
//

import Foundation

enum NetworkErrorConditions: Error {
    case badUrl
    case dataCannotHandled
}
// Singletion
class TLHttpClient {
    static let shared = TLHttpClient()
    func postAPILottery(url: URL,
                        lat: Double,
                        lon: Double,
                        distance: Double,
                        completion: @escaping(Result<CreateUserResponse, NetworkErrorConditions>) -> Void) {
        // response 多型 generic
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("0", forHTTPHeaderField: "Encrypt")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let user = CreateRequestBody(lat: lat, lon: lon, distance: distance)
        let data = try? encoder.encode(user)
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let createUserResponse = try decoder.decode(CreateUserResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(createUserResponse))
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
