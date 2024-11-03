//
//  LabelEventTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

@testable import NostrSDK
import XCTest

final class LabelEventTests: XCTestCase, EventVerifying {

    func testCreateLabelEvent() throws {
        let publicKey1 = try XCTUnwrap(Keypair()).publicKey
        let publicKey2 = try XCTUnwrap(Keypair()).publicKey
        let relayURL1 = try XCTUnwrap(URL(string: "wss://relay.nostrsdk.com"))
        let relayURL2 = try XCTUnwrap(URL(string: "wss://relay.damus.io"))
        let relayURL3 = try XCTUnwrap(URL(string: "wss://relay.primal.net"))
        let targetedEventCoordinates1 = try XCTUnwrap(EventCoordinates(kind: .bookmarksList, pubkey: publicKey1))
        let targetedEventCoordinates2 = try XCTUnwrap(EventCoordinates(kind: .bookmarksList, pubkey: publicKey2))

        let labelEvent = try LabelEvent.Builder()
            .appendLabels("approve", namespace: "nip28.moderation")
            .target(eventId: "event-id-1", relayURL: relayURL1)
            .target(eventId: "event-id-2", relayURL: relayURL2)
            .target(pubkey: publicKey1.hex, relayURL: relayURL2)
            .target(pubkey: publicKey2.hex, relayURL: relayURL3)
            .target(eventCoordinates: targetedEventCoordinates1)
            .target(eventCoordinates: targetedEventCoordinates2)
            .target(relayURL: relayURL3)
            .target(relayURL: relayURL1)
            .target(topic: "topic1")
            .target(topic: "topic2")
            .build(signedBy: .test)

        XCTAssertEqual(labelEvent.labels, ["nip28.moderation": ["approve"]])
        XCTAssertEqual(labelEvent.labels(for: "nip28.moderation"), ["approve"])
        XCTAssertEqual(labelEvent.labelNamespaces, ["nip28.moderation"])

        XCTAssertEqual(labelEvent.targetedEvents.count, 2)
        let targetedEventTag1 = try XCTUnwrap(labelEvent.targetedEvents[0])
        XCTAssertEqual(targetedEventTag1.eventId, "event-id-1")
        XCTAssertEqual(targetedEventTag1.relayURL?.absoluteString, relayURL1.absoluteString)
        let targetedEventTag2 = try XCTUnwrap(labelEvent.targetedEvents[1])
        XCTAssertEqual(targetedEventTag2.eventId, "event-id-2")
        XCTAssertEqual(targetedEventTag2.relayURL?.absoluteString, relayURL2.absoluteString)

        XCTAssertEqual(labelEvent.targetedPubkeys.count, 2)
        let targetedPubkey1 = try XCTUnwrap(labelEvent.targetedPubkeys[0])
        XCTAssertEqual(targetedPubkey1.pubkey, publicKey1.hex)
        XCTAssertEqual(targetedPubkey1.relayURL?.absoluteString, relayURL2.absoluteString)
        let targetedPubkey2 = try XCTUnwrap(labelEvent.targetedPubkeys[1])
        XCTAssertEqual(targetedPubkey2.pubkey, publicKey2.hex)
        XCTAssertEqual(targetedPubkey2.relayURL?.absoluteString, relayURL3.absoluteString)

        XCTAssertEqual(labelEvent.targetedEventCoordinates, [targetedEventCoordinates1, targetedEventCoordinates2])
        XCTAssertEqual(labelEvent.targetedRelayURLs.map { $0.absoluteString }, [relayURL3.absoluteString, relayURL1.absoluteString])
        XCTAssertEqual(labelEvent.targetedTopics, ["topic1", "topic2"])

        try verifyEvent(labelEvent)
    }

}
