//
//  PaymentMethodsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// Fetches the available payment methods
public protocol PaymentMethodsServiceAPI: class {
    var paymentMethods: Observable<[PaymentMethod]> { get }
    var paymentMethodsSingle: Single<[PaymentMethod]> { get }
    var supportedCardTypes: Single<Set<CardType>> { get }
    func fetch() -> Observable<[PaymentMethod]>
}

final class PaymentMethodsService: PaymentMethodsServiceAPI {
    
    // MARK: - Public properties
        
    var paymentMethods: Observable<[PaymentMethod]> {
        paymentMethodsRelay
            .flatMap(weak: self) { (self, paymentMethods) -> Observable<[PaymentMethod]> in
                guard let paymentMethods = paymentMethods else {
                    return self.fetch()
                }
                return .just(paymentMethods)
            }
            .distinctUntilChanged()
    }
    
    var paymentMethodsSingle: Single<[PaymentMethod]> {
        paymentMethodsRelay
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, paymentMethods) -> Single<[PaymentMethod]> in
                guard let paymentMethods = paymentMethods else {
                    return self.fetch().take(1).asSingle()
                }
                return .just(paymentMethods)
            }
    }
    
    var supportedCardTypes: Single<Set<CardType>> {
        paymentMethodsSingle.map { paymentMethods in
            guard let card = paymentMethods.first(where: { $0.type.isCard }) else {
                return []
            }
            switch card.type {
            case .card(let types):
                return types
            case .bankTransfer:
                return []
            }
        }
    }
        
    // MARK: - Private properties
    
    private let paymentMethodsRelay = BehaviorRelay<[PaymentMethod]?>(value: nil)
    
    private let client: PaymentMethodsClientAPI
    private let tiersService: KYCTiersServiceAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let featureFetcher: FeatureFetching
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    
    // MARK: - Setup
    
    init(client: PaymentMethodsClientAPI,
         tiersService: KYCTiersServiceAPI,
         reactiveWallet: ReactiveWalletAPI,
         featureFetcher: FeatureFetching,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        self.client = client
        self.tiersService = tiersService
        self.reactiveWallet = reactiveWallet
        self.featureFetcher = featureFetcher
        self.fiatCurrencyService = fiatCurrencyService
    }
    
    func fetch() -> Observable<[PaymentMethod]> {
        fiatCurrencyService.fiatCurrencyObservable
            .flatMap(weak: self) { (self, fiatCurrency) -> Observable<PaymentMethodsResponse> in
                self.tiersService.fetchTiers()
                    .map { $0.isTier2Approved }
                    .flatMap { isTier2Approved -> Single<PaymentMethodsResponse> in
                        self.client.paymentMethods(
                            for: fiatCurrency.code,
                            checkEligibility: isTier2Approved
                        )
                    }
                    .asObservable()
            }
            .map { Array<PaymentMethod>.init(response: $0) }
            .map {
                $0.filter {
                    switch $0.type {
                    case .card:
                        return true
                    case .bankTransfer:
                        // Filter out bank transfer details from currencies we do not
                        //  have local support/UI.
                        return BankLocallySupportedCurrencies
                            .fiatCurrencies
                            .contains($0.min.currencyType)
                    }
                }
            }
            .flatMap(weak: self) { (self, methods) -> Observable<[PaymentMethod]> in
                self.featureFetcher.fetchBool(for: .simpleBuyCardsEnabled)
                    .map { isEnabled in
                        guard !isEnabled else { return methods }
                        return methods.filter { !$0.type.isCard }
                    }
                    .asObservable()
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] paymentMethods in
                self?.paymentMethodsRelay.accept(paymentMethods)
            })
    }
}
