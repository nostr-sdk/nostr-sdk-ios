//
//  URLComponentsAdditionsTests.swift
//  
//
//  Created by Terry Yiu on 12/16/23.
//

import XCTest

final class URLComponentsAdditionsTests: XCTestCase {

    func testIsValidRelay() throws {
        XCTAssertFalse(try XCTUnwrap(URLComponents(string: "https://nostr.com")).isValidRelay)
        XCTAssertTrue(try XCTUnwrap(URLComponents(string: "ws://nostr.com")).isValidRelay)
        XCTAssertTrue(try XCTUnwrap(URLComponents(string: "wss://nostr.com")).isValidRelay)
    }

}
