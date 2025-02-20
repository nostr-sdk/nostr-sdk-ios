//
//  DeletionEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class DeletionEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateDeletionEventForRegularEvent() throws {
        let noteToDelete: TextNoteEvent = try decodeFixture(filename: "text_note_deletable")
        let longformNoteToDelete: LongformContentEvent = try decodeFixture(filename: "longform_deletable")
        let reason = "Didn't mean to post"

        let event = try delete(events: [noteToDelete, longformNoteToDelete], reason: reason, signedBy: Keypair.test)

        XCTAssertEqual(event.kind, .deletion)

        XCTAssertEqual(event.reason, "Didn't mean to post")
        XCTAssertEqual(event.deletedEventIds, ["fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b", "8f4b2477881ec73c824410610709163f6a4e8fda067de8c4bbd0a9e337901eac"])
        XCTAssertTrue(event.referencedEventCoordinates.isEmpty)
        XCTAssertTrue(event.eventCoordinates.isEmpty)

        try verifyEvent(event)
    }

    func testCreateDeletionEventForRegularEventFailsWithMismatchedPubkey() throws {
        let noteToDelete: TextNoteEvent = try decodeFixture(filename: "text_note")
        let reason = "Didn't mean to post"

        XCTAssertThrowsError(try delete(events: [noteToDelete], reason: reason, signedBy: Keypair.test))
    }

    func testCreateDeletionEventForAddressableEvent() throws {
        let longformNoteToDelete: LongformContentEvent = try decodeFixture(filename: "longform_deletable")
        let longformNoteEventCoordinates = try XCTUnwrap(longformNoteToDelete.replaceableEventCoordinates(relayURL: nil))
        let reason = "Didn't mean to post"

        let event = try delete(replaceableEvents: [longformNoteToDelete], reason: reason, signedBy: Keypair.test)

        XCTAssertEqual(event.kind, .deletion)

        XCTAssertEqual(event.reason, "Didn't mean to post")
        XCTAssertEqual(event.referencedEventCoordinates, [longformNoteEventCoordinates])
        XCTAssertEqual(event.eventCoordinates, [longformNoteEventCoordinates])
        XCTAssertTrue(event.deletedEventIds.isEmpty)

        try verifyEvent(event)
    }

    func testCreateDeletionEventForAddressableEventFailsWithMismatchedPubkey() throws {
        let longformNoteToDelete: LongformContentEvent = try decodeFixture(filename: "longform")
        let reason = "Didn't mean to post"

        XCTAssertThrowsError(try delete(replaceableEvents: [longformNoteToDelete], reason: reason, signedBy: Keypair.test))
    }

    func testDecodeDeletionEvent() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "deletion")

        XCTAssertEqual(event.id, "6ff64ff18b898a9039b3c9a09574b1bb2f6197b0782ab416cf1251eaff296ca3")
        XCTAssertEqual(event.pubkey, "2779f3d9f42c7dee17f0e6bcdcf89a8f9d592d19e3b1bbd27ef1cffd1a7f98d1")
        XCTAssertEqual(event.createdAt, 1713356767)
        XCTAssertEqual(event.kind, .deletion)

        let expectedTags: [Tag] = [
            .event("69ba6336507d20f6673e5866be32583e0d0ae61a4149c04f2d48d124671e5aff")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "")
        XCTAssertEqual(event.signature, "f672f285ef3506509b6b12ffcfaf90f234ed9895894a989f9c7b69023b600dd0544b36edc81f0889928e637f53fe34444c62e82d4f5add46c5b7a283d02e207d")

        XCTAssertEqual(event.referencedEventIds, ["69ba6336507d20f6673e5866be32583e0d0ae61a4149c04f2d48d124671e5aff"])
        XCTAssertEqual(event.mentionedEventIds, ["69ba6336507d20f6673e5866be32583e0d0ae61a4149c04f2d48d124671e5aff"])
    }

}
