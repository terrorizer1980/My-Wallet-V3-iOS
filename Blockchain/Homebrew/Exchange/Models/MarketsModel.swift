//
//  MarketsModel.swift
//  Blockchain
//
//  Created by kevinwu on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
 
/// `MarketPair` is to keep track of what accounts
/// the user is transferring from and to. We originally
/// used just a `TradingPair` but some users may have
/// multiple wallets of the same asset type.
struct MarketPair {
    let fromAccount: AssetAccount
    let toAccount: AssetAccount
}

extension MarketPair {
    var pair: TradingPair {
        let from = fromAccount.address.cryptoCurrency
        let to = toAccount.address.cryptoCurrency
        return TradingPair(from: from, to: to)!
    }
}

// State model for interacting with the MarketsService
class MarketsModel {
    var marketPair: MarketPair
    var fiatCurrency: FiatCurrency
    var fiatCurrencyCode: String {
        fiatCurrency.code
    }
    var fiatCurrencySymbol: String {
        fiatCurrency.symbol
    }
    var fix: Fix
    var volume: String
    var lastConversion: Conversion?

    init(marketPair: MarketPair,
         fiatCurrency: FiatCurrency,
         fix: Fix,
         volume: String) {
        self.marketPair = marketPair
        self.fiatCurrency = fiatCurrency
        self.fix = fix
        self.volume = volume
    }
}

extension MarketsModel {
    var pair: TradingPair {
        marketPair.pair
    }
    
    var cryptoValue: CryptoValue? {
        CryptoValue.createFromMajorValue(string: volume, assetType: pair.from)
    }
}

extension MarketsModel {
    var isUsingFiat: Bool {
        fix == .baseInFiat || fix == .counterInFiat
    }

    var isUsingBase: Bool {
        fix == .base || fix == .baseInFiat
    }

    func toggleFiatInput() {
        switch fix {
        case .base:
            fix = .baseInFiat
        case .baseInFiat:
            fix = .base
        case .counter:
            fix = .counterInFiat
        case .counterInFiat:
            fix = .counter
        }
    }

    func toggleFix() {
        fix = fix.toggledFix()
    }
}

extension MarketsModel: Equatable {
    // Do not compare lastConversion
    static func == (lhs: MarketsModel, rhs: MarketsModel) -> Bool {
        lhs.pair == rhs.pair
            && lhs.fiatCurrency == rhs.fiatCurrency
            && lhs.fix == rhs.fix
            && lhs.volume == rhs.volume
    }
}
