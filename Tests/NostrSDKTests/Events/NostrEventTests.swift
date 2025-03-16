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

    func testNevent() throws {
        let relay1 = "wss://relay1.com"
        let relay2 = "wss://relay2.com"

        let textNoteEvent: TextNoteEvent = try decodeFixture(filename: "text_note")
        let shareableEventIdentifier = try XCTUnwrap(textNoteEvent.nevent(relayURLStrings: [relay1, relay2]))
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

}
