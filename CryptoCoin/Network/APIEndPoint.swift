//
//  APIEndPoint.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation

enum CurrencyAPI {
    case getCoins
    case getCoin(String)
    case coinHistory(String)
}

enum SecretAPIKeys {
    static let CoinAPIio = "1ECF60CD-5C10-44AC-9E0F-B7F4867A5133"
    static let CoinrankingAPIKey = "coinrankingd1726ef042d54541b22c8c36e717e38e409a48855107212d"
}

extension CurrencyAPI {
    
    var urlRequest: URLRequest {
        return URLRequest(url: URL(string: self.urlString)!)
    }
    
    var urlString: String {
        return self.baseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!
    }
    
    var baseURL: URL{
        switch self {
        case .getCoins, .getCoin, .coinHistory:
            return URL(string: "https://api.coinranking.com/v2/")!
        }
    }
    
    var path: String {
        switch self {
        case .getCoins:
            return "coins"
        case .getCoin(let id):
            return "/coin/\(id)"
        case .coinHistory(let id):
            return "/coin/\(id)/history"
        }
    }
}

