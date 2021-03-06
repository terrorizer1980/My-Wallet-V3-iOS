//
//  TransactionalLineItem.swift
//  Blockchain
//
//  Created by Paulo on 14/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import ToolKit

public enum TransactionalLineItem: Hashable {
    typealias AccessibilityID = Accessibility.Identifier.LineItem.Transactional
    typealias LocalizedString = LocalizationConstants.LineItem.Transactional

    case amount(_ content: String? = nil)
    case `for`(_ content: String? = nil)
    case value(_ content: String? = nil)
    case fee(_ content: String? = nil)
    case buyingFee(_ content: String? = nil)
    case date(_ content: String? = nil)
    case estimatedAmount(_ content: String? = nil)
    case exchangeRate(_ content: String? = nil)
    case orderId(_ content: String? = nil)
    case paymentAccountField(PaymentAccountProperty.Field)
    case paymentMethod(_ content: String? = nil)
    case status(_ content: String? = nil)
    case totalCost(_ content: String? = nil)
    case from(_ content: String? = nil)
    case to(_ content: String? = nil)
    case gasFor(_ content: String? = nil)
    case memo(_ content: String? = nil)

    public var accessibilityID: String {
        switch self {
        case .amount:
            return AccessibilityID.amount
        case .for:
            return AccessibilityID.for
        case .value:
            return AccessibilityID.value
        case .fee:
            return AccessibilityID.fee
        case .buyingFee:
            return AccessibilityID.buyingFee
        case .date:
            return AccessibilityID.date
        case .estimatedAmount:
            return AccessibilityID.estimatedAmount
        case .exchangeRate:
            return AccessibilityID.exchangeRate
        case .orderId:
            return AccessibilityID.orderId
        case .paymentAccountField(let field):
            return field.accessibilityID
        case .paymentMethod:
            return AccessibilityID.paymentMethod
        case .status:
            return AccessibilityID.status
        case .totalCost:
            return AccessibilityID.totalCost
        case .from:
            return AccessibilityID.from
        case .to:
            return AccessibilityID.to
        case .gasFor:
            return AccessibilityID.gasFor
        case .memo:
            return AccessibilityID.memo
        }
    }

    public var content: String? {
        switch self {
        case .amount(let content),
             .buyingFee(let content),
             .date(let content),
             .estimatedAmount(let content),
             .exchangeRate(let content),
             .orderId(let content),
             .paymentMethod(let content),
             .status(let content),
             .to(let content),
             .from(let content),
             .gasFor(let content),
             .memo(let content),
             .value(let content),
             .fee(let content),
             .for(let content),
             .totalCost(let content):
            return content
        case .paymentAccountField(let field):
            return field.content
        }
    }

    public var title: String {
        switch self {
        case .amount:
            return LocalizedString.amount
        case .value:
            return LocalizedString.value
        case .fee:
            return LocalizedString.fee
        case .for:
            return LocalizedString.for
        case .buyingFee:
            return LocalizedString.buyingFee
        case .date:
            return LocalizedString.date
        case .estimatedAmount:
            return LocalizedString.estimatedAmount
        case .exchangeRate:
            return LocalizedString.exchangeRate
        case .orderId:
            return LocalizedString.orderId
        case .paymentAccountField(let field):
            return field.title
        case .paymentMethod:
            return LocalizedString.paymentMethod
        case .status:
            return LocalizedString.status
        case .totalCost:
            return LocalizedString.totalCost
        case .to:
            return LocalizedString.to
        case .from:
            return LocalizedString.from
        case .gasFor:
            return LocalizedString.gasFor
        case .memo:
            return LocalizedString.memo
        }
    }

    public func defaultPresenter(accessibilityIdPrefix: String) -> DefaultLineItemCellPresenter {
        let interactor = DefaultLineItemCellInteractor(
            title: DefaultLabelContentInteractor(knownValue: title),
            description: DefaultLabelContentInteractor(knownValue: content ?? "")
        )
        return DefaultLineItemCellPresenter(
            interactor: interactor,
            accessibilityIdPrefix: "\(accessibilityIdPrefix)\(accessibilityID)"
        )
    }

    public var descriptionInteractionText: String {
        typealias LocalizedCopyable = LocalizedString.Copyable
        switch self {
        case .paymentAccountField(.iban):
            return "\(LocalizedCopyable.iban) \(LocalizedCopyable.copyMessageSuffix)"
        case .paymentAccountField(.bankCode):
            return "\(LocalizedCopyable.bankCode) \(LocalizedCopyable.copyMessageSuffix)"
        default:
            return LocalizedCopyable.defaultCopyMessage
        }
    }

    public func defaultCopyablePresenter(
        analyticsEvent: AnalyticsEvent? = nil,
        analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording,
        accessibilityIdPrefix: String
    ) -> PasteboardingLineItemCellPresenter {

        PasteboardingLineItemCellPresenter(
            input: .init(
                title: title,
                titleInteractionText: LocalizedString.Copyable.copied,
                description: content ?? "",
                descriptionInteractionText: descriptionInteractionText,
                analyticsEvent: analyticsEvent
            ),
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: "\(accessibilityIdPrefix)\(accessibilityID)"
        )
    }
}

extension PaymentAccountProperty.Field {
    public var accessibilityID: String {
        typealias AccessibilityID = Accessibility.Identifier.LineItem.Transactional
        switch self {
        case .accountNumber:
            return AccessibilityID.accountNumber
        case .sortCode:
            return AccessibilityID.sortCode
        case .recipientName:
            return AccessibilityID.recipient
        case .bankName:
            return AccessibilityID.bankName
        case .bankCountry:
            return AccessibilityID.bankCountry
        case .iban:
            return AccessibilityID.iban
        case .bankCode:
            return AccessibilityID.bankCode
        }
    }
}
