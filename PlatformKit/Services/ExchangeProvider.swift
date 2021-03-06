//
//  ExchangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A provider for exchange rates as per supported crypto.
public protocol ExchangeProviding: class {
    
    /// Returns the exchange service
    subscript(currency: CryptoCurrency) -> PairExchangeServiceAPI { get }
    
    /// Refreshes all the exchange rates
    func refresh()
}

public final class ExchangeProvider: ExchangeProviding {
    
    public subscript(currency: CryptoCurrency) -> PairExchangeServiceAPI {
        services[currency]!
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: PairExchangeServiceAPI] = [:]
    
    // MARK: - Setup
    
    public init(algorand: PairExchangeServiceAPI,
                ether: PairExchangeServiceAPI,
                pax: PairExchangeServiceAPI,
                stellar: PairExchangeServiceAPI,
                bitcoin: PairExchangeServiceAPI,
                bitcoinCash: PairExchangeServiceAPI,
                tether: PairExchangeServiceAPI) {
        services[.algorand] = algorand
        services[.ethereum] = ether
        services[.pax] = pax
        services[.stellar] = stellar
        services[.bitcoin] = bitcoin
        services[.bitcoinCash] = bitcoinCash
        services[.tether] = tether
    }
    
    public func refresh() {
        services.values.forEach { $0.fetchTriggerRelay.accept(()) }
    }
}
