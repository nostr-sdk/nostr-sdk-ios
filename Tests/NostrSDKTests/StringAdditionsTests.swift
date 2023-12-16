//
//  StringAdditionsTests.swift
//  
//
//  Created by Terry Yiu on 12/16/23.
//

import XCTest

final class StringAdditionsTests: XCTestCase {

    func testRelayURL() throws {
        XCTAssertNil("".relayURL)
        XCTAssertNil("https://nostr.com".relayURL)
        XCTAssertEqual("ws://nostr.com".relayURL, URL(string: "ws://nostr.com"))
        XCTAssertEqual("wss://nostr.com".relayURL, URL(string: "wss://nostr.com"))
    }

}
