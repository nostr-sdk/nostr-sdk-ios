//
//  RelayResponseDecodingTests.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

@testable import NostrSDK
import XCTest

final class RelayResponseDecodingTests: XCTestCase, FixtureLoading {

    func testDecodeEventMessage() throws {
        let data = try loadFixtureData("event")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .event(let subscriptionId, let event) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(subscriptionId, "some-subscription-id")
        XCTAssertNotNil(event)
        XCTAssertTrue(event is TextNoteEvent)
        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
    }

    func testDecodeOkMessage() throws {
        let data = try loadFixtureData("ok_success")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .ok(let eventId, let success, let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
        XCTAssertEqual(success, true)
        XCTAssertEqual(message.prefix, .unknown)
        XCTAssertEqual(message.message, "")
    }

    func testDecodeOkMessageWithReason() throws {
        let data = try loadFixtureData("ok_success_reason")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .ok(let eventId, let success, let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
        XCTAssertEqual(success, true)
        XCTAssertEqual(message.prefix, .pow)
        XCTAssertEqual(message.message, "difficulty: 25>=24")
    }

    func testDecodeOkMessageWithReasonPrefixNoMessage() throws {
        let data = try loadFixtureData("ok_success_reason_prefix_no_message")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .ok(let eventId, let success, let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
        XCTAssertEqual(success, true)
        XCTAssertEqual(message.prefix, .pow)
        XCTAssertEqual(message.message, "")
    }

    func testDecodeOkMessageWithUnknownReason() throws {
        let data = try loadFixtureData("ok_unknown_reason")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .ok(let eventId, let success, let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
        XCTAssertEqual(success, true)
        XCTAssertEqual(message.prefix, .unknown)
        XCTAssertEqual(message.message, "unknown: reason: unknown")
    }

    func testDecodeOkFailWithReason() throws {
        let data = try loadFixtureData("ok_fail_reason")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .ok(let eventId, let success, let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(eventId, "b1a649ebe8b435ec71d3784793f3bbf4b93e64e17568a741aecd4c7ddeafce30")
        XCTAssertEqual(success, false)
        XCTAssertEqual(message.prefix, .blocked)
        XCTAssertEqual(message.message, "tor exit nodes not allowed")
    }

    func testDecodeEOSEMessage() throws {
        let data = try loadFixtureData("eose")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .eose(let subscriptionId) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(subscriptionId, "some-subscription-id")
    }

    func testDecodeClosedMessage() throws {
        let data = try loadFixtureData("closed")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .closed(let subscriptionId, let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(subscriptionId, "some-subscription-id")
        XCTAssertEqual(message.prefix, .error)
        XCTAssertEqual(message.message, "shutting down idle subscription")
    }

    func testDecodeNoticeMessage() throws {
        let data = try loadFixtureData("notice")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .notice(let message) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(message, "there was an error")
    }

    func testDecodeAuthChallenge() throws {
        let data = try loadFixtureData("auth_challenge")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .auth(let challenge) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(challenge, "some-challenge-string")
    }

    func testDecodeCount() throws {
        let data = try loadFixtureData("count_response")

        let relayResponse = try XCTUnwrap(RelayResponse.decode(data: data))
        guard case .count(let subscriptionId, let count) = relayResponse else {
            XCTFail("incorrect type")
            return
        }
        XCTAssertEqual(subscriptionId, "subscription-id")
        XCTAssertEqual(count, 238)
    }
}
