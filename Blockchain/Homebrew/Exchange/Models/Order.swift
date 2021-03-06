//
//  Order.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

enum Side: String {
    case buy = "BUY"
    case sell = "SELL"
}

struct Order: Encodable {
    let destinationAddress: String
    let refundAddress: String
    let quote: Quote
}

struct OrderResult: Codable {
    let id: String
    let state: String
    let createdAt: String
    let updatedAt: String
    let pair: String
    let refundAddress: String
    let rate: String
    let depositAddress: String
    let deposit: SymbolValue
    let withdrawalAddress: String
    let withdrawal: SymbolValue
    let withdrawalFee: SymbolValue
    let fiatValue: SymbolValue
    let depositMemo: String?

    private enum CodingKeys: CodingKey {
        case id
        case state
        case createdAt
        case updatedAt
        case pair
        case refundAddress
        case rate
        case depositAddress
        case deposit
        case withdrawalAddress
        case withdrawal
        case withdrawalFee
        case fiatValue
        case depositMemo
    }
}

@objc class OrderTransactionLegacy: NSObject {
    init(
        legacyAssetType: LegacyAssetType,
        from: Int32,
        to: String,
        amount: String,
        fees: String?,
        gasLimit: String?
    ) {
        self.legacyAssetType = legacyAssetType
        self.from = from
        self.to = to
        self.amount = amount
        self.fees = fees
        self.gasLimit = gasLimit
        super.init()
    }
    @objc let legacyAssetType: LegacyAssetType
    @objc let from: Int32
    @objc let to: String
    @objc let amount: String
    @objc var fees: String?
    @objc var gasLimit: String?
}

struct OrderTransaction {
    let orderIdentifier: String?

    // The destination is where the user will ultimately receive
    // funds from the exchange.
    let destination: AssetAccount

    // Details of payment constructed in Wallet JS
    let from: AssetAccount
    let to: AssetAddress
    let amountToSend: String
    let amountToReceive: String
    let fees: String
}
