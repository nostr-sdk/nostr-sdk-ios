//
//  EventCoordinatesTests.swift
//
//
//  Created by Terry Yiu on 12/16/23.
//

import XCTest
@testable import NostrSDK

final class EventCoordinatesTests: XCTestCase {

    func testInit() throws {
        let kind: EventKind = .longformContent
        let pubkey = Keypair.test.publicKey
        let identifier = "F8SII-G5LDumDZgxGCVQS"
        let relay = "wss://relay.nostrsdk.com"

        let eventCoordinates = try XCTUnwrap(
            EventCoordinates(
                kind: kind,
                pubkey: pubkey,
                identifier: identifier,
                relayURL: URL(string: relay)
            )
        )

        XCTAssertEqual(eventCoordinates.kind, kind)
        XCTAssertEqual(eventCoordinates.pubkey, pubkey)
        XCTAssertEqual(eventCoordinates.identifier, identifier)
        XCTAssertEqual(eventCoordinates.relayURL?.absoluteString, relay)
    }

    func testInitFromTag() throws {
        let tag = Tag(name: .eventCoordinates, value: "30023:a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919:ipsum", otherParameters: ["wss://relay.nostr.org"])

        let eventCoordinates = try XCTUnwrap(
            EventCoordinates(eventCoordinatesTag: tag)
        )

        XCTAssertEqual(eventCoordinates.kind?.rawValue, 30023)
        XCTAssertEqual(eventCoordinates.pubkey?.hex, "a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919")
        XCTAssertEqual(eventCoordinates.identifier, "ipsum")
        XCTAssertEqual(eventCoordinates.relayURL?.absoluteString, "wss://relay.nostr.org")
    }

    func testInitFromTagAndInvalidRelayURL() throws {
        let tag = Tag(name: .eventCoordinates, value: "30023:a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919:ipsum", otherParameters: ["https://relay.nostr.org"])

        let eventCoordinates = try XCTUnwrap(
            EventCoordinates(eventCoordinatesTag: tag)
        )

        XCTAssertEqual(eventCoordinates.kind?.rawValue, 30023)
        XCTAssertEqual(eventCoordinates.pubkey?.hex, "a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919")
        XCTAssertEqual(eventCoordinates.identifier, "ipsum")

        // If the coordinates came from a relay but the relay URL is malformed, the rest of the data may still be valid.
        // Rather than just failing the initialization, we will just return nil if relayURL is called.
        XCTAssertNil(eventCoordinates.relayURL)
    }

    func testInitFailsOnNonReplaceableEvent() throws {
        XCTAssertThrowsError(
            try EventCoordinates(
                kind: .textNote,
                pubkey: Keypair.test.publicKey
            )
        )
    }

    func testInitFailsOnNonParameterizedReplaceableEventWithIdentifier() throws {
        XCTAssertThrowsError(
            try EventCoordinates(
                kind: .metadata,
                pubkey: Keypair.test.publicKey,
                identifier: "should-fail"
            )
        )
    }

    func testInitFailsOnParameterizedReplaceableEventWithoutIdentifier() throws {
        XCTAssertThrowsError(
            try EventCoordinates(
                kind: .longformContent,
                pubkey: Keypair.test.publicKey
            )
        )
    }

    func testInitFailsOnInvalidRelayURL() throws {
        XCTAssertThrowsError(
            try EventCoordinates(
                kind: .longformContent,
                pubkey: Keypair.test.publicKey,
                identifier: "F8SII-G5LDumDZgxGCVQS",
                relayURL: URL(string: "https://relay.nostrsdk.com")
            )
        )
    }

}
