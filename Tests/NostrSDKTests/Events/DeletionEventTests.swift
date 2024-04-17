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
        XCTAssertTrue(event.eventCoordinates.isEmpty)

        try verifyEvent(event)
    }

    func testCreateDeletionEventForRegularEventFailsWithMismatchedPubkey() throws {
        let noteToDelete: TextNoteEvent = try decodeFixture(filename: "text_note")
        let reason = "Didn't mean to post"

        XCTAssertThrowsError(try delete(events: [noteToDelete], reason: reason, signedBy: Keypair.test))
    }

    func testCreateDeletionEventForParameterizedReplaceableEvent() throws {
        let longformNoteToDelete: LongformContentEvent = try decodeFixture(filename: "longform_deletable")
        let longformNoteEventCoordinates = try XCTUnwrap(longformNoteToDelete.replaceableEventCoordinates(relayURL: nil))
        let reason = "Didn't mean to post"

        let event = try delete(replaceableEvents: [longformNoteToDelete], reason: reason, signedBy: Keypair.test)

        XCTAssertEqual(event.kind, .deletion)

        XCTAssertEqual(event.reason, "Didn't mean to post")
        XCTAssertEqual(event.eventCoordinates, [longformNoteEventCoordinates])
        XCTAssertTrue(event.deletedEventIds.isEmpty)

        try verifyEvent(event)
    }

    func testCreateDeletionEventForParameterizedReplaceableEventFailsWithMismatchedPubkey() throws {
        let longformNoteToDelete: LongformContentEvent = try decodeFixture(filename: "longform")
        let reason = "Didn't mean to post"

        XCTAssertThrowsError(try delete(replaceableEvents: [longformNoteToDelete], reason: reason, signedBy: Keypair.test))
    }

}
