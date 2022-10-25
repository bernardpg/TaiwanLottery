//
//  HttpClient.swift
//  TaiwanLottery
//
//  Created by 1ms20p on 2022/10/17.
//

import Foundation
// Singletion
class HttpClient {
    static let shared = HttpClient()
//    (Result<CreateUserResponse, Error>) -> Void)
    func postAPILottery(url: URL, lat: Double,
                        lon: Double, distance: Double,
                        completion: @escaping (CreateUserResponse) -> Void) {
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
                        completion(createUserResponse)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}

//        request.httpBody = postData
//      let jsonString = String(data: data, encoding: .utf8)!
//        let parameters = "{\n  \"lat\": 25.0802004,\n  \"lon\": 121.5714038,\n  \"distance\": 3\n}"
 //       let postData = parameters.data(using: .utf8)
//        print(postData)
