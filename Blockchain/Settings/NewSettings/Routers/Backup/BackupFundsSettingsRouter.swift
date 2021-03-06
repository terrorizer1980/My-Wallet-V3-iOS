//
//  BackupFundsSettingsRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class BackupFundsSettingsRouter: BackupRouterAPI, Router {
    
    // MARK: - BackupRouterAPI
    
    let entry: BackupRouterEntry = .settings
    let completionRelay = PublishRelay<Void>()
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
    
    private var stateService: BackupRouterStateService!
    private let serviceProvider: BackupFundsServiceProviderAPI
    private let disposeBag = DisposeBag()
    
    init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         services: BackupFundsServiceProviderAPI = BackupFundsServiceProvider.default,
         navigationControllerAPI: NavigationControllerAPI?) {
        self.navigationControllerAPI = navigationControllerAPI
        self.serviceProvider = services
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }
    
    func start() {
        stateService = BackupRouterStateService(entry: entry)
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .complete:
                    self.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
                    self.completionRelay.accept(())
                case .dismiss:
                    self.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: BackupRouterStateService.State) {
        switch state {
        case .start, .end:
            break
        case .backupFunds(let presentationType, let entry):
            showBackupFunds(presentationType: presentationType, entry: entry)
        case .recovery:
            let presenter = RecoveryPhraseScreenPresenter(stateService: stateService, serviceProvider: serviceProvider)
            let controller = RecoveryPhraseViewController(presenter: presenter)
            navigationControllerAPI?.pushViewController(controller, animated: true)
        case .verification:
            let presenter = VerifyBackupScreenPresenter(stateService: stateService, service: serviceProvider.recoveryPhraseVerifyingAPI)
            let controller = VerifyBackupViewController(presenter: presenter)
            navigationControllerAPI?.pushViewController(controller, animated: true)
        }
    }
    
    func previous() {
        dismiss()
    }
    
    // MARK: - Private Functions
    
    private func showBackupFunds(presentationType: PresentationType, entry: BackupRouterEntry) {
        let presenter = BackupFundsScreenPresenter(stateService: stateService, entry: entry)
        let controller = BackupFundsViewController(presenter: presenter)
        if #available(iOS 13.0, *) {
            controller.isModalInPresentation = true
        }
        present(viewController: controller, using: presentationType)
    }
}

