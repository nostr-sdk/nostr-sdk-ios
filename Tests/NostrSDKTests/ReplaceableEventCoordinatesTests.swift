//
//  ReplaceableEventCoordinatesTests.swift
//
//
//  Created by Terry Yiu on 12/16/23.
//

import XCTest
@testable import NostrSDK

final class ReplaceableEventCoordinatesTests: XCTestCase {

    func testInit() throws {
        let kind: EventKind = .longformContent
        let pubkey = Keypair.test.publicKey
        let identifier = "F8SII-G5LDumDZgxGCVQS"
        let relay = "wss://relay.nostrsdk.com"

        let replaceableEventCoordinates = try XCTUnwrap(
            ReplaceableEventCoordinates(
                kind: kind,
                pubkey: pubkey,
                identifier: identifier,
                relayURL: URL(string: relay)
            )
        )

        XCTAssertEqual(replaceableEventCoordinates.kind, kind)
        XCTAssertEqual(replaceableEventCoordinates.pubkey, pubkey)
        XCTAssertEqual(replaceableEventCoordinates.identifier, identifier)
        XCTAssertEqual(replaceableEventCoordinates.relayURL?.absoluteString, relay)
    }

    func testInitFromTag() throws {
        let tag = Tag(name: .replaceableEvent, value: "30023:a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919:ipsum", otherParameters: ["wss://relay.nostr.org"])

        let replaceableEventCoordinates = try XCTUnwrap(
            ReplaceableEventCoordinates(replaceableEventTag: tag)
        )

        XCTAssertEqual(replaceableEventCoordinates.kind?.rawValue, 30023)
        XCTAssertEqual(replaceableEventCoordinates.pubkey?.hex, "a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919")
        XCTAssertEqual(replaceableEventCoordinates.identifier, "ipsum")
        XCTAssertEqual(replaceableEventCoordinates.relayURL?.absoluteString, "wss://relay.nostr.org")
    }

    func testInitFromTagAndInvalidRelayURL() throws {
        let tag = Tag(name: .replaceableEvent, value: "30023:a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919:ipsum", otherParameters: ["https://relay.nostr.org"])

        let replaceableEventCoordinates = try XCTUnwrap(
            ReplaceableEventCoordinates(replaceableEventTag: tag)
        )

        XCTAssertEqual(replaceableEventCoordinates.kind?.rawValue, 30023)
        XCTAssertEqual(replaceableEventCoordinates.pubkey?.hex, "a695f6b60119d9521934a691347d9f78e8770b56da16bb255ee286ddf9fda919")
        XCTAssertEqual(replaceableEventCoordinates.identifier, "ipsum")

        // If the coordinates came from a relay but the relay URL is malformed, the rest of the data may still be valid.
        // Rather than just failing the initialization, we will just return nil if relayURL is called.
        XCTAssertNil(replaceableEventCoordinates.relayURL)
    }

    func testInitFailsOnInvalidRelayURL() throws {
        XCTAssertNil(
            ReplaceableEventCoordinates(
                kind: .longformContent,
                pubkey: Keypair.test.publicKey,
                identifier: "F8SII-G5LDumDZgxGCVQS",
                relayURL: URL(string: "https://relay.nostrsdk.com")
            )
        )
    }

}
