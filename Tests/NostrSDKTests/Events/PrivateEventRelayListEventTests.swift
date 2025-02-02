//
//  PrivateEventRelayListEventTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 2/2/25.
//

@testable import NostrSDK
import XCTest

final class PrivateEventRelayListEventTests: XCTestCase, RelayURLValidating {

    func testCreatePrivateEventRelayListEvent() throws {
        let relay1 = try XCTUnwrap(URL(string: "wss://relay.damus.io"))
        let relay2 = try XCTUnwrap(URL(string: "wss://relay.primal.net"))

        let privateEventRelayListEvent = try PrivateEventRelayListEvent.Builder()
            .relayURLs([relay1, relay2], encryptedWith: .test)
            .build(signedBy: .test)

        XCTAssertEqual(try privateEventRelayListEvent.relayURLs(decryptedWith: .test), [relay1, relay2])
    }

}
