//
//  RelayListMetadataEventTests.swift
//  
//
//  Created by Terry Yiu on 7/14/24.
//

@testable import NostrSDK
import XCTest

final class RelayListMetadataEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateRelayListMetadata() throws {
        let relayURL1 = try XCTUnwrap(URL(string: "wss://relay.primal.net"))
        let relayURL2 = try XCTUnwrap(URL(string: "wss://relay.damus.io"))
        let relayURL3 = try XCTUnwrap(URL(string: "wss://relay.snort.social"))

        let expectedRelayMetadataList: [UserRelayMetadata] = [
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL1, marker: .read)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL2, marker: .write)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL3, marker: .readAndWrite))
        ]
        let event = try XCTUnwrap(relayListMetadataEvent(withRelayMetadataList: expectedRelayMetadataList, signedBy: Keypair.test))

        let expectedEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .relayListMetadata, pubkey: Keypair.test.publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(), expectedEventCoordinates)

        let tag1 = Tag(name: "r", value: relayURL1.absoluteString, otherParameters: ["read"])
        let tag2 = Tag(name: "r", value: relayURL2.absoluteString, otherParameters: ["write"])
        let tag3 = Tag(name: "r", value: relayURL3.absoluteString)
        XCTAssertEqual(event.tags, [tag1, tag2, tag3])

        let relayMetadataList = event.relayMetadataList
        XCTAssertEqual(relayMetadataList.count, expectedRelayMetadataList.count)

        XCTAssertEqual(relayMetadataList[0].relayURL.absoluteString, relayURL1.absoluteString)
        XCTAssertEqual(relayMetadataList[0].marker, .read)
        XCTAssertEqual(relayMetadataList[0].tag, tag1)
        XCTAssertEqual(relayMetadataList[1].relayURL.absoluteString, relayURL2.absoluteString)
        XCTAssertEqual(relayMetadataList[1].marker, .write)
        XCTAssertEqual(relayMetadataList[1].tag, tag2)
        XCTAssertEqual(relayMetadataList[2].relayURL.absoluteString, relayURL3.absoluteString)
        XCTAssertEqual(relayMetadataList[2].marker, .readAndWrite)
        XCTAssertEqual(relayMetadataList[2].tag, tag3)

        try verifyEvent(event)
    }

    func testCreateRelayListMetadataWithDuplicates() throws {
        let relayURL1 = try XCTUnwrap(URL(string: "wss://relay.primal.net"))
        let relayURL2 = try XCTUnwrap(URL(string: "wss://relay.damus.io"))
        let relayURL3 = try XCTUnwrap(URL(string: "wss://relay.snort.social"))
        let relayURL4 = try XCTUnwrap(URL(string: "wss://relay.nostrsdk.com"))
        let relayURL5 = try XCTUnwrap(URL(string: "wss://relay.coracle.social"))
        let relayURL6 = try XCTUnwrap(URL(string: "wss://relay.nostr.band"))

        let relayMetadataListWithDuplicates: [UserRelayMetadata] = [
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL1, marker: .read)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL2, marker: .write)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL3, marker: .read)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL4, marker: .readAndWrite)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL5, marker: .write)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL6, marker: .read)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL6, marker: .read)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL5, marker: .write)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL4, marker: .write)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL3, marker: .readAndWrite)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL2, marker: .read)),
            try XCTUnwrap(UserRelayMetadata(relayURL: relayURL1, marker: .write))
        ]
        let event = try XCTUnwrap(relayListMetadataEvent(withRelayMetadataList: relayMetadataListWithDuplicates, signedBy: Keypair.test))

        let expectedEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .relayListMetadata, pubkey: Keypair.test.publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(), expectedEventCoordinates)

        let tag1 = Tag(name: "r", value: relayURL1.absoluteString)
        let tag2 = Tag(name: "r", value: relayURL2.absoluteString)
        let tag3 = Tag(name: "r", value: relayURL3.absoluteString)
        let tag4 = Tag(name: "r", value: relayURL4.absoluteString)
        let tag5 = Tag(name: "r", value: relayURL5.absoluteString, otherParameters: ["write"])
        let tag6 = Tag(name: "r", value: relayURL6.absoluteString, otherParameters: ["read"])
        XCTAssertEqual(event.tags, [tag1, tag2, tag3, tag4, tag5, tag6])

        let relayMetadataList = event.relayMetadataList
        XCTAssertEqual(relayMetadataList.count, 6)

        XCTAssertEqual(relayMetadataList[0].relayURL.absoluteString, relayURL1.absoluteString)
        XCTAssertEqual(relayMetadataList[0].marker, .readAndWrite)
        XCTAssertEqual(relayMetadataList[0].tag, tag1)
        XCTAssertEqual(relayMetadataList[1].relayURL.absoluteString, relayURL2.absoluteString)
        XCTAssertEqual(relayMetadataList[1].marker, .readAndWrite)
        XCTAssertEqual(relayMetadataList[1].tag, tag2)
        XCTAssertEqual(relayMetadataList[2].relayURL.absoluteString, relayURL3.absoluteString)
        XCTAssertEqual(relayMetadataList[2].marker, .readAndWrite)
        XCTAssertEqual(relayMetadataList[2].tag, tag3)
        XCTAssertEqual(relayMetadataList[3].relayURL.absoluteString, relayURL4.absoluteString)
        XCTAssertEqual(relayMetadataList[3].marker, .readAndWrite)
        XCTAssertEqual(relayMetadataList[3].tag, tag4)
        XCTAssertEqual(relayMetadataList[4].relayURL.absoluteString, relayURL5.absoluteString)
        XCTAssertEqual(relayMetadataList[4].marker, .write)
        XCTAssertEqual(relayMetadataList[4].tag, tag5)
        XCTAssertEqual(relayMetadataList[5].relayURL.absoluteString, relayURL6.absoluteString)
        XCTAssertEqual(relayMetadataList[5].marker, .read)
        XCTAssertEqual(relayMetadataList[5].tag, tag6)

        try verifyEvent(event)
    }

    func testDecodeRelayListMetadata() throws {
        let event: RelayListMetadataEvent = try decodeFixture(filename: "relay_list_metadata")
        XCTAssertEqual(event.id, "68962e8499c2067306b2daaa8811b95f38d5e7b8954976d15a8419751a96757a")
        XCTAssertEqual(event.pubkey, "cb9f20cbd8616dcb79ce1dbdcec702b9b1549e678225ce035b31db4d820f4418")
        XCTAssertEqual(event.createdAt, 1720822990)
        XCTAssertEqual(event.kind, .relayListMetadata)
        XCTAssertEqual(event.content, "")
        XCTAssertEqual(event.signature, "0b40f4f5de3f6cb2223a7961d7b2a3c8f3b5944a275dc27ba3cea765f6be127fb311f10218e25001bee0e30ac6a2ed7dfa45d8c77e3973ce599eaa0bd1e2423b")

        let publicKey = try XCTUnwrap(PublicKey(hex: event.pubkey))
        let expectedEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .relayListMetadata, pubkey: publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(), expectedEventCoordinates)

        let tag1 = Tag(name: "r", value: "wss://relay.momostr.pink/")
        let tag2 = Tag(name: "r", value: "wss://relay.primal.net/", otherParameters: ["read"])
        let tag3 = Tag(name: "r", value: "wss://relay.nostr.band/", otherParameters: ["read"])

        XCTAssertEqual(event.tags, [tag1, tag2, tag3])

        XCTAssertEqual(event.relayMetadataList.count, 3)
        XCTAssertEqual(event.relayMetadataList[0].relayURL.absoluteString, "wss://relay.momostr.pink/")
        XCTAssertEqual(event.relayMetadataList[0].marker, .readAndWrite)
        XCTAssertEqual(event.relayMetadataList[0].tag, tag1)
        XCTAssertEqual(event.relayMetadataList[1].relayURL.absoluteString, "wss://relay.primal.net/")
        XCTAssertEqual(event.relayMetadataList[1].marker, .read)
        XCTAssertEqual(event.relayMetadataList[1].tag, tag2)
        XCTAssertEqual(event.relayMetadataList[2].relayURL.absoluteString, "wss://relay.nostr.band/")
        XCTAssertEqual(event.relayMetadataList[2].marker, .read)
        XCTAssertEqual(event.relayMetadataList[2].tag, tag3)
    }

    func testDecodeRelayListMetadataWithInvalidTags() throws {
        let event: RelayListMetadataEvent = try decodeFixture(filename: "relay_list_metadata_invalid_tags")
        XCTAssertEqual(event.id, "68962e8499c2067306b2daaa8811b95f38d5e7b8954976d15a8419751a96757a")
        XCTAssertEqual(event.pubkey, "cb9f20cbd8616dcb79ce1dbdcec702b9b1549e678225ce035b31db4d820f4418")
        XCTAssertEqual(event.createdAt, 1720822990)
        XCTAssertEqual(event.kind, .relayListMetadata)
        XCTAssertEqual(event.content, "")
        XCTAssertEqual(event.signature, "0b40f4f5de3f6cb2223a7961d7b2a3c8f3b5944a275dc27ba3cea765f6be127fb311f10218e25001bee0e30ac6a2ed7dfa45d8c77e3973ce599eaa0bd1e2423b")

        let publicKey = try XCTUnwrap(PublicKey(hex: event.pubkey))
        let expectedEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .relayListMetadata, pubkey: publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(), expectedEventCoordinates)

        let tag1 = Tag(name: "r", value: "wss://relay.momostr.pink/", otherParameters: ["invalid-marker"])
        let tag2 = Tag(name: "r", value: "wss://relay.primal.net/", otherParameters: ["read", "this-should-be-ignored"])
        let tag3 = Tag(name: "r", value: "https://invalid-nostr-relay.com/", otherParameters: ["read"])

        XCTAssertEqual(event.tags, [tag1, tag2, tag3])

        XCTAssertEqual(event.relayMetadataList.count, 1)
        XCTAssertEqual(event.relayMetadataList[0].relayURL.absoluteString, "wss://relay.primal.net/")
        XCTAssertEqual(event.relayMetadataList[0].marker, .read)
        XCTAssertEqual(event.relayMetadataList[0].tag, Tag(name: "r", value: "wss://relay.primal.net/", otherParameters: ["read"]))
    }

}
