//
//  FollowListEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class FollowListEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateFollowListEvent() throws {
        let pubkeys = [
            "83y9iuhw9u0t8thw8w80u",
            "19048ut34h23y89jio3r8",
            "5r623gyewfbh8uuiq83rd"
        ]

        let event = try followList(withPubkeys: pubkeys,
                                    signedBy: Keypair.test)

        let expectedTags: [Tag] = [
            .pubkey("83y9iuhw9u0t8thw8w80u"),
            .pubkey("19048ut34h23y89jio3r8"),
            .pubkey("5r623gyewfbh8uuiq83rd")
        ]

        XCTAssertEqual(event.tags, expectedTags)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .followList, pubkey: Keypair.test.publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(event)
    }

    func testCreateFollowListEventWithPetnames() throws {
        let tags: [Tag] = [
            .pubkey("83y9iuhw9u0t8thw8w80u", otherParameters: ["bob"]),
            .pubkey("19048ut34h23y89jio3r8", otherParameters: ["alice"]),
            .pubkey("5r623gyewfbh8uuiq83rd", otherParameters: ["steve"])
        ]

        let event = try followList(withPubkeyTags: tags,
                                    signedBy: Keypair.test)

        XCTAssertEqual(event.tags, tags)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .followList, pubkey: Keypair.test.publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(event)
    }

    func testDecodeFollowList() throws {

        let event: FollowListEvent = try decodeFixture(filename: "follow_list")

        XCTAssertEqual(event.id, "test-id")
        XCTAssertEqual(event.pubkey, "test-pubkey")
        XCTAssertEqual(event.createdAt, 1684817569)
        XCTAssertEqual(event.kind, .followList)

        let expectedTags: [Tag] = [
            .pubkey("pubkey1", otherParameters: ["wss://relay1.com", "alice"]),
            .pubkey("pubkey2", otherParameters: ["wss://relay2.com", "bob"])
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.signature, "hex-signature")
    }

    func testDecodeFollowListWithRelays() throws {
        let event: FollowListEvent = try decodeFixture(filename: "follow_list_with_relays")

        let expectedPubkeys = [
            "3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681",
            "07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f",
            "020f2d21ae09bf35fcdfb65decf1478b846f5f728ab30c5eaabcd6d081a81c3e",
            "58c741aa630c2da35a56a77c1d05381908bd10504fdd2d8b43f725efa6d23196",
            "59fbee7369df7713dbbfa9bbdb0892c62eba929232615c6ff2787da384cb770f"
        ]

        XCTAssertEqual(event.followedPubkeys, expectedPubkeys)

        let firstTag = Tag.pubkey("3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681")
        XCTAssertEqual(event.followedPubkeyTags.first, firstTag)

        let expectedRelays = [
            "wss://relay.damus.io": RelayPermissions(read: true, write: true),
            "wss://relay.current.fyi": RelayPermissions(read: false, write: true),
            "wss://eden.nostr.land": RelayPermissions(read: true, write: true),
            "wss://relay.snort.social": RelayPermissions(read: true, write: false),
            "wss://nos.lol": RelayPermissions(read: true, write: true)
        ]

        XCTAssertEqual(event.relays, expectedRelays)
    }

}
