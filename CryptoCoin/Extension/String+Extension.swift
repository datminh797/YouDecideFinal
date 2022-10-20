//
//  String+Extension.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation

extension String {
    
    var convertToDouble: Double {
        Double(self) ?? 0.0
    }
    
    var convertToInt: Int {
        Int(self) ?? 0
    }
    
    func convertToDate() -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        return dateFormatter.date(from: self)
    }
    
    func convertToDisplayFormat() -> String {
        
        guard let date = self.convertToDate2() else {
            return "N/A"
        }
        
        return date.convertToMonthDayYear()
    }
    
    func convertToDate2() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withFractionalSeconds
        dateFormatter.timeZone = .current
        return dateFormatter.date(from: self)
        
    }
    
    func formattedNumber() -> String {
        let numbersOnlyEquivalent = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        return numbersOnlyEquivalent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func removeFormatAmount() -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol
        formatter.decimalSeparator = Locale.current.groupingSeparator
        return formatter.number(from: self)?.doubleValue ?? 0.00
    }
    
    func convertToCurrency() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.locale = .current
        let number = NSNumber(value: Double(self) ?? 0)
        if let currency = currencyFormatter.string(from: number) {
            return "$" + currency
        }
        return "$0"
    }
}

