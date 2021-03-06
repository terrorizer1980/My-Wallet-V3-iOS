//
//  SimpleBuyQuoteTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 26/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BuySellKit
@testable import PlatformKit
import XCTest

class SimpleBuyQuoteTests: XCTestCase {

    struct QuoteTestCase {
        let locale: Locale
        let response: QuoteResponse
        let quote: Quote!

    }
    func createTestCases(locales: [Locale]) -> [QuoteTestCase] {
        locales.map { createTestCase(locale: $0) }
    }
    func createTestCase(locale: Locale) -> QuoteTestCase {
        let response = QuoteResponse(time: "2020-03-26T11:04:35.144Z", rate: "577864", rateWithoutFee: "576864", fee: "1000")
        let quote: Quote? = try? Quote(to: .bitcoin,
                                                         amount: FiatValue(minor: "500", currency: .GBP),
                                                         response: response)
        return QuoteTestCase(locale: locale, response: response, quote: quote)
    }
    func testAllRegions() {
        let sut = createTestCases(locales: [.US, .Canada, .GreatBritain, .France, .Japan, .Lithuania])
        for this in sut {
            XCTAssertNotNil(this.quote)
            XCTAssertFalse(this.quote.estimatedAmount.isZero, "\(this.locale) has zero estimatedAmount")
            XCTAssertEqual(this.quote.fee.string, "0.86525", "\(this.locale) fee minor value should be 0.86525")
        }
    }
}
