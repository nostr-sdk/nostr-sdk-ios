//
//  RelayResponseDecodingTests.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

@testable import NostrSDK
import XCTest

final class RelayResponseDecodingTests: XCTestCase, FixtureLoading {

    func testDecodeNoticeMessage() throws {
        let data = try loadFixtureData("notice")

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

    func testDecodeEOSEMessage() throws {
        let data = try loadFixtureData("eose")

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

    func testDecodeEventMessage() throws {
        let data = try loadFixtureData("event")

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

    func testDecodeOkMessage() throws {
        let data = try loadFixtureData("ok_success")

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .ok(let eventId, let success, let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
            XCTAssertEqual(success, true)
            XCTAssertEqual(message.type, .unknown)
            XCTAssertNil(message.message)
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeOkMessageWithReason() throws {
        let data = try loadFixtureData("ok_success_reason")

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .ok(let eventId, let success, let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
            XCTAssertEqual(success, true)
            XCTAssertEqual(message.type, .pow)
            XCTAssertEqual(message.message, "difficulty 25>=24")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeOkFailWithReason() throws {
        let data = try loadFixtureData("ok_fail_reason")

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .ok(let eventId, let success, let message) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
            XCTAssertEqual(success, false)
            XCTAssertEqual(message.type, .blocked)
            XCTAssertEqual(message.message, "tor exit nodes not allowed")
        } else {
            XCTFail("failed to decode")
        }
    }

    func testDecodeCount() throws {
        let data = try loadFixtureData("count_response")

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

    func testDecodeAuthChallenge() throws {
        let data = try loadFixtureData("auth_challenge")

        if let relayResponse = RelayResponse.decode(data: data) {
            guard case .auth(let challenge) = relayResponse else {
                XCTFail("incorrect type")
                return
            }
            XCTAssertEqual(challenge, "some-challenge-string")
        } else {
            XCTFail("failed to decode")
        }
    }
}
