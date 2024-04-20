//
//  NostrEventTests.swift
//  
//
//  Created by Terry Yiu on 4/19/24.
//

@testable import NostrSDK
import XCTest

final class NostrEventTests: XCTestCase, FixtureLoading {

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

}
