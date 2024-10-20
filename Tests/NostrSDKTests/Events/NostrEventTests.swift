//
//  NostrEventTests.swift
//  
//
//  Created by Terry Yiu on 4/19/24.
//

@testable import NostrSDK
import XCTest

final class NostrEventTests: XCTestCase, FixtureLoading, MetadataCoding {

    func testEquatable() throws {
        let textNoteEvent: TextNoteEvent = try decodeFixture(filename: "text_note")
        let nostrEvent: NostrEvent = try decodeFixture(filename: "text_note")
        let differentEvent: NostrEvent = NostrEvent(
            id: nostrEvent.id,
            pubkey: nostrEvent.pubkey,
            createdAt: nostrEvent.createdAt,
            kind: nostrEvent.kind,
            tags: nostrEvent.tags,
            content: "This content was written by an impersonator.",
            signature: nostrEvent.signature
        )

        XCTAssertEqual(textNoteEvent, nostrEvent)
        XCTAssertNotEqual(nostrEvent, differentEvent)
    }

    func testHashable() throws {
        let textNoteEvent: TextNoteEvent = try decodeFixture(filename: "text_note")
        let nostrEvent: NostrEvent = try decodeFixture(filename: "text_note")
        let differentEvent: NostrEvent = NostrEvent(
            id: nostrEvent.id,
            pubkey: nostrEvent.pubkey,
            createdAt: nostrEvent.createdAt,
            kind: nostrEvent.kind,
            tags: nostrEvent.tags,
            content: "This content was written by an impersonator.",
            signature: nostrEvent.signature
        )

        XCTAssertEqual(textNoteEvent.hashValue, nostrEvent.hashValue)
        XCTAssertNotEqual(nostrEvent.hashValue, differentEvent.hashValue)
    }

    func testBech32NoteId() throws {
        let textNoteEvent: TextNoteEvent = try decodeFixture(filename: "text_note")
        let bech32NoteId = textNoteEvent.bech32NoteId
        XCTAssertEqual(bech32NoteId, "note1lf0dsn7ga6u4nlfe4k8yswyvlseswkv3a789qpjvlnk0myvthydshz7qeg")
    }

    func testShareableEventIdentifier() throws {
        let relay1 = "wss://relay1.com"
        let relay2 = "wss://relay2.com"

        let textNoteEvent: TextNoteEvent = try decodeFixture(filename: "text_note")
        let shareableEventIdentifier = try XCTUnwrap(textNoteEvent.shareableEventIdentifier(relayURLStrings: [relay1, relay2]))
        XCTAssertEqual(shareableEventIdentifier, "nevent1qqs05hkcflywaw2el5u6mrjg8zx0cvc8txg7lrjsqex0em8ajx9mjxcpzpmhxue69uhhyetvv9unztnrdakszyrhwden5te0wfjkcctexghxxmmdqgsgydql3q4ka27d9wnlrmus4tvkrnc8ftc4h8h5fgyln54gl0a7dgsrqsqqqqqplcac7m")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventIdentifier))
        XCTAssertEqual(metadata.eventId, textNoteEvent.id)
        XCTAssertNil(metadata.identifier)
        XCTAssertEqual(metadata.pubkey, textNoteEvent.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(textNoteEvent.kind.rawValue))
        XCTAssertEqual(metadata.relays?.count, 2)
        XCTAssertEqual(metadata.relays?[0], relay1)
        XCTAssertEqual(metadata.relays?[1], relay2)
    }

    func testAlternativeSummary() throws {
        let alternativeSummary = "Alternative summary to display for clients that do not support this event kind."
        let customEvent = try NostrEvent.Builder(kind: EventKind(rawValue: 23456))
            .alternativeSummary(alternativeSummary)
            .build(signedBy: .test)
        XCTAssertEqual(customEvent.alternativeSummary, alternativeSummary)

        let decodedCustomEventWithAltTag: NostrEvent = try decodeFixture(filename: "custom_event_alt_tag")
        XCTAssertEqual(decodedCustomEventWithAltTag.alternativeSummary, alternativeSummary)
    }

    func testExpiration() throws {
        let futureExpiration = Int64(Date.now.timeIntervalSince1970 + 10000)
        let futureExpirationEvent = try NostrEvent.Builder(kind: .textNote)
            .expiration(futureExpiration)
            .build(signedBy: .test)
        XCTAssertEqual(futureExpirationEvent.expiration, futureExpiration)
        XCTAssertFalse(futureExpirationEvent.isExpired)

        let pastExpiration = Int64(Date.now.timeIntervalSince1970 - 1)
        let pastExpirationEvent = try NostrEvent.Builder(kind: .textNote)
            .expiration(pastExpiration)
            .build(signedBy: .test)
        XCTAssertEqual(pastExpirationEvent.expiration, pastExpiration)
        XCTAssertTrue(pastExpirationEvent.isExpired)

        let decodedExpiredEvent: NostrEvent = try decodeFixture(filename: "test_event_expired")
        XCTAssertEqual(decodedExpiredEvent.expiration, 1697090842)
        XCTAssertTrue(decodedExpiredEvent.isExpired)
    }

}
