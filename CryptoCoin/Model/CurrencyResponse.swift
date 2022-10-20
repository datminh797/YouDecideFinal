//
//  CurrencyResponse.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation

struct CurrencyResponse: Codable {
    let status: String
    let data: CurrencyData
}
struct CurrencyData: Codable {
    let currencies: [Currency]
   
}

struct Currency: Codable {
    let uuid: String
    let type: TypeEnum
    let iconURL: String?
    let name, symbol: String
    let sign: String?

    enum CodingKeys: String, CodingKey {
        case uuid, type
        case iconURL = "iconUrl"
        case name, symbol, sign
    }
}

enum TypeEnum: String, Codable {
    case coin = "coin"
    case denominator = "denominator"
    case fiat = "fiat"
}
