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

    func testDecodeOkMessage() {
        guard let data = fixtureLoader.loadFixture("ok_success") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .ok(let eventId, let success, let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
            XCTAssertEqual(success, true)
            XCTAssertEqual(message, "")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeOkMessageWithReason() {
        guard let data = fixtureLoader.loadFixture("ok_success_reason") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .ok(let eventId, let success, let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
            XCTAssertEqual(success, true)
            XCTAssertEqual(message, "pow: difficulty 25>=24")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeOkFailWithReason() {
        guard let data = fixtureLoader.loadFixture("ok_fail_reason") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .ok(let eventId, let success, let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
            XCTAssertEqual(success, false)
            XCTAssertEqual(message, "blocked: tor exit nodes not allowed")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeCount() {
        guard let data = fixtureLoader.loadFixture("count_response") else {
            XCTFail("failed to load fixture")
            return
        }

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .count(let subscriptionId, let count) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(subscriptionId, "subscription-id")
            XCTAssertEqual(count, 238)
        } else {
            XCTFail("failed to decode")
        }
    }
}
