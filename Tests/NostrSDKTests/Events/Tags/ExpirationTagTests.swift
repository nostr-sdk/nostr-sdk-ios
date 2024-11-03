//
//  ExpirationTagTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

@testable import NostrSDK
import XCTest

final class ExpirationTagTests: XCTestCase, FixtureLoading {

    func testExpiration() throws {
        let futureExpiration = Int64(Date.now.timeIntervalSince1970 + 10000)
        let futureExpirationEvent = try NostrEvent.Builder(kind: .textNote)
            .expiration(futureExpiration)
            .build(signedBy: .test)
        XCTAssertEqual(futureExpirationEvent.expiration, futureExpiration)
        XCTAssertFalse(futureExpirationEvent.isExpired)

        let pastExpiration = Int64(Date.now.timeIntervalSince1970 - 1)
        let pastExpirationEvent = try NostrEvent.Builder(kind: .textNote)
            .expiration(pastExpiration)
            .build(signedBy: .test)
        XCTAssertEqual(pastExpirationEvent.expiration, pastExpiration)
        XCTAssertTrue(pastExpirationEvent.isExpired)

        let decodedExpiredEvent: NostrEvent = try decodeFixture(filename: "test_event_expired")
        XCTAssertEqual(decodedExpiredEvent.expiration, 1697090842)
        XCTAssertTrue(decodedExpiredEvent.isExpired)
    }

}
