//
//  RelayInformationTests.swift
//  
//
//  Created by Bryan Montz on 6/4/23.
//

@testable import NostrSDK
import XCTest

final class RelayInfoTests: XCTestCase, FixtureLoading {

    func testDecodeRelayInformation() throws {
        let info: RelayInfo = try decodeFixture(filename: "relay_info")
        
        XCTAssertEqual(info.name, "nostr.test")
        XCTAssertEqual(info.description, "Nostr Test")
        XCTAssertEqual(info.contactPubkey, "test-pubkey")
        XCTAssertEqual(info.alternativeContact, "mailto:somebody@nostr.test")
        XCTAssertEqual(info.supportedNIPs, [1, 2, 4, 9])
        XCTAssertEqual(info.software, "git+https://github.com/Cameri/nostream.git")
        XCTAssertEqual(info.version, "1.25.2")
        XCTAssertEqual(info.relayCountries, ["CA", "US"])
        XCTAssertEqual(info.paymentsURL, "https://nostr.test/invoices")
        XCTAssertEqual(info.languageTags, ["en", "es"])
        XCTAssertEqual(info.tags, ["sfw-only", "bitcoin-only", "anime"])
        XCTAssertEqual(info.postingPolicyURL, "https://nostr.test/posting-policy.html")
        
        XCTAssertEqual(info.limitations?.maxMessageLength, 1048576)
        XCTAssertEqual(info.limitations?.maxSubscriptions, 10)
        XCTAssertEqual(info.limitations?.maxFilters, 2500)
        XCTAssertEqual(info.limitations?.maxLimit, 5000)
        XCTAssertEqual(info.limitations?.maxSubscriptionIdLength, 256)
        XCTAssertEqual(info.limitations?.minPrefix, 4)
        XCTAssertEqual(info.limitations?.maxEventTags, 2500)
        XCTAssertEqual(info.limitations?.maxContentLength, 65536)
        XCTAssertEqual(info.limitations?.minProofOfWorkDifficulty, 0)
        XCTAssertEqual(info.limitations?.isAuthenticationRequired, false)
        XCTAssertEqual(info.limitations?.isPaymentRequired, true)
        
        let admissionFee = try XCTUnwrap(info.fees?.admission?.first)
        XCTAssertEqual(admissionFee.amount, 1000000)
        XCTAssertEqual(admissionFee.unit, "msats")
        XCTAssertNil(admissionFee.period)
        XCTAssertNil(admissionFee.kinds)
        
        let subscriptionFee = try XCTUnwrap(info.fees?.subscription?.first)
        XCTAssertEqual(subscriptionFee.amount, 5000000)
        XCTAssertEqual(subscriptionFee.unit, "msats")
        XCTAssertEqual(subscriptionFee.period, 2592000)
        XCTAssertNil(subscriptionFee.kinds)
        
        let publicationFee = try XCTUnwrap(info.fees?.publication?.first)
        XCTAssertEqual(publicationFee.amount, 100)
        XCTAssertEqual(publicationFee.unit, "msats")
        XCTAssertNil(publicationFee.period)
        XCTAssertEqual(publicationFee.kinds, [4])
        
        let kind1Policy = try XCTUnwrap(info.retentionPolicy(forKind: 1))
        XCTAssertEqual(kind1Policy.time, 3600)
        XCTAssertNil(kind1Policy.count)
        
        let kind30kPolicy = try XCTUnwrap(info.retentionPolicy(forKind: 31234))
        XCTAssertEqual(kind30kPolicy.count, 1000)
        XCTAssertNil(kind30kPolicy.time)
        
        let unspecifiedKindRetention = try XCTUnwrap(info.retentionPolicy(forKind: 75))
        XCTAssertEqual(unspecifiedKindRetention.time, 3600)
        XCTAssertEqual(unspecifiedKindRetention.count, 10000)
    }
}
