//
//  ERC20ActivityDetailsInteractor.swift
//  Blockchain
//
//  Created by Paulo on 15/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit
import RxSwift

final class ERC20ActivityDetailsInteractor {
    
    // MARK: - Private Properties

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    private let wallet: EthereumWalletBridgeAPI
    private let cryptoCurrency: CryptoCurrency
    
    // MARK: - Init

    init(wallet: EthereumWalletBridgeAPI = WalletManager.shared.wallet.ethereum,
         fiatCurrencySettings: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         priceService: PriceServiceAPI = PriceService(),
         serviceProvider: ETHServiceProvider = ETHServiceProvider.shared,
         cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
        self.detailsService = serviceProvider.services.activityDetails
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
        self.wallet = wallet
    }

    // MARK: - Public Functions
    
    func details(identifier: String, createdAt: Date) -> Observable<ERC20ActivityDetailsViewModel> {
        let transaction = detailsService
            .details(for: identifier)
        let price = self.price(at: createdAt)
            .optional()
            .catchErrorJustReturn(nil)

        return Observable
            .combineLatest(
                transaction,
                price.asObservable()
            )
            .map { ERC20ActivityDetailsViewModel(details: $0, price: $1?.priceInFiat) }
    }
    
    // MARK: - Private Functions
    
    private func price(at date: Date) -> Single<PriceInFiatValue> {
        fiatCurrencySettings
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.price(at: date, in: fiatCurrency)
            }
    }

    private func price(at date: Date, in fiatCurrency: FiatCurrency) -> Single<PriceInFiatValue> {
        priceService.price(
            for: cryptoCurrency,
            in: fiatCurrency,
            at: date
        )
    }
}
