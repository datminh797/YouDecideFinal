//
//  NetworkManager.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    var currencyUsd: String {
        "yhjMzLPhuIDl"
    }
    let cache = NSCache<NSString, UIImage>()
    public var imageURLViewModel: [String: String] = [:]
    var allCoins: [Coins]?
    
    func getAllCoins(completion: @escaping (CoinsResponse?, Error?) -> Void) {
        let request = CurrencyAPI.getCoins.urlRequest
        self.getRequest(url: request.url!, responseType: CoinsResponse.self) { response, error in
            if let response = response {
                self.allCoins = response.data.coins
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getSingleCoin(uuid: String,completion: @escaping (SingleCoinResponse?, Error?) ->Void) {
        let urlComps = URLComponents(string: CurrencyAPI.getCoin(uuid).urlString)!
        self.getRequest(url: urlComps.url!, responseType: SingleCoinResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getHistory(coin: String, type: HistoryDays, completion: @escaping (HistoryResponse?, Error?) -> Void) {
        var urlComps = URLComponents(string: CurrencyAPI.coinHistory(coin).urlString)!
        let queryItem = [URLQueryItem(name: "referenceCurrencyUuid", value: currencyUsd ),URLQueryItem(name: "timePeriod", value: type.description)]
        urlComps.queryItems = queryItem
        self.getRequest(url: urlComps.url!, responseType: HistoryResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.addValue(SecretAPIKeys.CoinrankingAPIKey, forHTTPHeaderField: "x-access-token")
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
        
}
