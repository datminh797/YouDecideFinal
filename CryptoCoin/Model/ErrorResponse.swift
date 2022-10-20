//
//  ErrorResponse.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation
struct ErrorResponse: Codable {
    let status, type, message: String
}
