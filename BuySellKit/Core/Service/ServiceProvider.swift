//
//  ServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

public final class ServiceProvider: ServiceProviderAPI {
    
    // MARK: - Properties

    public let eligibility: EligibilityServiceAPI
    public let orderCancellation: OrderCancellationServiceAPI
    public var orderCompletion: PendingOrderCompletionServiceAPI {
        PendingOrderCompletionService(ordersService: ordersDetails)
    }
    public let orderConfirmation: OrderConfirmationServiceAPI
    public let ordersDetails: OrdersServiceAPI
    public let paymentMethodTypes: PaymentMethodTypesServiceAPI
    public let pendingOrderDetails: PendingOrderDetailsServiceAPI
    public let suggestedAmounts: SuggestedAmountsServiceAPI
    public let supportedCurrencies: SupportedCurrenciesServiceAPI
    public let supportedPairs: SupportedPairsServiceAPI
    public let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    public let paymentMethods: PaymentMethodsServiceAPI

    public let cache: EventCache

    public let orderCreation: OrderCreationServiceAPI
    public let orderQuote: OrderQuoteServiceAPI
    public let paymentAccount: PaymentAccountServiceAPI
    
    public let settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI
    public let dataRepository: DataRepositoryAPI

    // MARK: - Setup
    
    public convenience init(cardServiceProvider: CardServiceProviderAPI,
                            recordingProvider: RecordingProviderAPI,
                            wallet: ReactiveWalletAPI,
                            cacheSuite: CacheSuite,
                            settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI,
                            dataRepository: DataRepositoryAPI,
                            tiersService: KYCTiersServiceAPI,
                            featureFetcher: FeatureFetching) {
        self.init(cardServiceProvider: cardServiceProvider,
                  recordingProvider: recordingProvider,
                  wallet: wallet,
                  simpleBuyClient: APIClient(),
                  cacheSuite: cacheSuite,
                  settings: settings,
                  dataRepository: dataRepository,
                  tiersService: tiersService,
                  featureFetcher: featureFetcher)
    }
    
    init(cardServiceProvider: CardServiceProviderAPI,
         recordingProvider: RecordingProviderAPI,
         wallet: ReactiveWalletAPI,
         simpleBuyClient: SimpleBuyClientAPI,
         cacheSuite: CacheSuite,
         settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI,
         dataRepository: DataRepositoryAPI,
         tiersService: KYCTiersServiceAPI,
         featureFetcher: FeatureFetching) {
        
        cache = EventCache(cacheSuite: cacheSuite)
        
        supportedPairs = SupportedPairsService(client: simpleBuyClient)
        
        supportedPairsInteractor = SupportedPairsInteractorService(
            featureFetcher: featureFetcher,
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )
        suggestedAmounts = SuggestedAmountsService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            fiatCurrencySettingsService: settings
        )
        ordersDetails = OrdersService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient
        )
        eligibility = EligibilityService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            fiatCurrencyService: settings,
            featureFetcher: featureFetcher
        )
        orderQuote = OrderQuoteService(
            client: simpleBuyClient
        )
        paymentAccount = PaymentAccountService(
            client: simpleBuyClient,
            dataRepository: dataRepository,
            fiatCurrencyService: settings,
            patcher: PaymentAccountPatcher()
        )
        orderConfirmation = OrderConfirmationService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient
        )
        orderCancellation = OrderCancellationService(
            client: simpleBuyClient,
            orderDetailsService: ordersDetails
        )
        pendingOrderDetails = PendingOrderDetailsService(
            ordersService: ordersDetails,
            cancallationService: orderCancellation
        )
        orderCreation = OrderCreationService(
            analyticsRecorder: recordingProvider.analytics,
            client: simpleBuyClient,
            pendingOrderDetailsService: pendingOrderDetails
        )
        paymentMethods = PaymentMethodsService(
            client: simpleBuyClient,
            tiersService: tiersService,
            reactiveWallet: wallet,
            featureFetcher: featureFetcher,
            fiatCurrencyService: settings
        )
        paymentMethodTypes = PaymentMethodTypesService(
            paymentMethodsService: paymentMethods,
            cardListService: cardServiceProvider.cardList
        )
        supportedCurrencies = SupportedCurrenciesService(
            featureFetcher: featureFetcher,
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )

        self.dataRepository = dataRepository
        self.settings = settings
    }
    
    public func orderCreation(for paymentMethod: PaymentMethod.MethodType) -> PendingOrderCreationServiceAPI {
        switch paymentMethod {
        case .bankTransfer:
            return BankOrderCreationService(
                paymentAccountService: paymentAccount,
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        case .card:
            return CardOrderCreationService(
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        }
    }
}
