//
//  RelayMessageDecodingTests.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

@testable import NostrSDK
import XCTest

final class RelayMessageDecodingTests: XCTestCase {

    let fixtureLoader = FixtureLoader()

    func testDecodeNoticeMessage() {
        guard let data = fixtureLoader.loadFixture("notice") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .notice(let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(message, "there was an error")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeEOSEMessage() {
        guard let data = fixtureLoader.loadFixture("eose") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .eose(let subscriptionId) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(subscriptionId, "some-subscription-id")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeEventMessage() {
        guard let data = fixtureLoader.loadFixture("event") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .event(let subscriptionId, let event) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(subscriptionId, "some-subscription-id")
            XCTAssertNotNil(event)
            XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        } else {
            XCTFail("failed to decode")
        }
    }
}
