//
//  CoinsResponse.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation
struct CoinsResponse: Codable {
    let status: String
    let data: DataClass
}

struct DataClass: Codable {
    let stats: Stats
    let coins: [Coins]
}

struct Coins: Codable {
    let uuid, symbol, name: String
    let color: String?
    let iconURL: String
    let marketCap, price: String
    let listedAt, tier: Int
    let change: String?
    let rank: Int
    let sparkline: [String?]
    let lowVolume: Bool
    let coinrankingURL: String
    let the24HVolume, btcPrice: String

    enum CodingKeys: String, CodingKey {
        case uuid, symbol, name, color
        case iconURL = "iconUrl"
        case marketCap, price, listedAt, tier, change, rank, sparkline, lowVolume
        case coinrankingURL = "coinrankingUrl"
        case the24HVolume = "24hVolume"
        case btcPrice
    }
    
    var description: String { symbol + name }
}

struct Stats: Codable {
    let total, totalMarkets, totalExchanges: Int
    let totalMarketCap, total24hVolume: String
}
