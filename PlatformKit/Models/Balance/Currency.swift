//
//  Currency.swift
//  PlatformKit
//
//  Created by Jack Pooley on 25/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum CurrencyError: Error {
    case unknownCurrency
}

public protocol Currency {
    var name: String { get }
    var code: String { get }
    var symbol: String { get }
    var displayCode: String { get }
    var maxDecimalPlaces: Int { get }
    var maxDisplayableDecimalPlaces: Int { get }
    var isFiatCurrency: Bool { get }
    var isCryptoCurrency: Bool { get }
}

extension Currency {
    public var isFiatCurrency: Bool {
        self is FiatCurrency
    }

    public var isCryptoCurrency: Bool {
        self is CryptoCurrency
    }
}

public enum CurrencyType: Equatable, Hashable {
    case fiat(FiatCurrency)
    case crypto(CryptoCurrency)
    
    /// Instantiate a Currency type from a currency code (e.g. `EUR`, `BTC`)
    /// - Parameter currency: a currency code, in the case of fiat any ISO 4217 code, for crypto any supported crypto
    /// - Throws: if the value is not a know fiat or crypto
    public init(currency: String) throws {
        if let cryptoCurrency = CryptoCurrency(code: currency) {
            self = .crypto(cryptoCurrency)
            return
        }
        if let fiatCurrency = FiatCurrency(code: currency) {
            self = .fiat(fiatCurrency)
            return
        }
        throw CurrencyError.unknownCurrency
    }
}

extension CurrencyType: Currency {
    public var name: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.name
        case .fiat(let fiatCurrency):
            return fiatCurrency.name
        }
    }
    
    public var code: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.code
        case .fiat(let fiatCurrency):
            return fiatCurrency.code
        }
    }
    
    public var symbol: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.symbol
        case .fiat(let fiatCurrency):
            return fiatCurrency.symbol
        }
    }
    
    public var displayCode: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.displayCode
        case .fiat(let fiatCurrency):
            return fiatCurrency.displayCode
        }
    }
    
    public var maxDecimalPlaces: Int {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.maxDecimalPlaces
        case .fiat(let fiatCurrency):
            return fiatCurrency.maxDecimalPlaces
        }
    }
    
    public var maxDisplayableDecimalPlaces: Int {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.maxDisplayableDecimalPlaces
        case .fiat(let fiatCurrency):
            return fiatCurrency.maxDisplayableDecimalPlaces
        }
    }
}

extension CryptoCurrency: Currency {}

extension FiatCurrency: Currency {
    public var displayCode: String {
        code
    }
    
    public var maxDisplayableDecimalPlaces: Int {
        maxDecimalPlaces
    }
}

extension CryptoCurrency {
    public var currency: CurrencyType {
        // swiftlint:disable:next force_try
        try! CurrencyType(currency: self.rawValue)
    }
}

extension FiatCurrency {
    public var currency: CurrencyType {
        // swiftlint:disable:next force_try
        try! CurrencyType(currency: self.rawValue)
    }
}

extension CryptoValue {
    public var currency: CurrencyType {
        currencyType.currency
    }
}

extension FiatValue {
    public var currency: CurrencyType {
        currencyType.currency
    }
}
