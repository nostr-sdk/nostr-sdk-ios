//
//  DraftPrivateWrapEventTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 2/2/25.
//

@testable import NostrSDK
import XCTest

final class DraftPrivateWrapEventTests: XCTestCase, EventVerifying, FixtureLoading {

    func testCreateDraftPrivateWrapEvent() throws {
        let textNoteEvent: TextNoteEvent = try decodeFixture(filename: "text_note")
        let longformContentEvent: LongformContentEvent = try decodeFixture(filename: "longform")
        let timeBasedCalendarEvent: TimeBasedCalendarEvent = try decodeFixture(filename: "time_based_calendar_event")

        let relayURL = try XCTUnwrap(URL(string: "wss://relay.damus.io"))

        let identifier = UUID().uuidString

        let anchorEventTag1 = try XCTUnwrap(EventTag(eventId: textNoteEvent.id, relayURL: relayURL))
        let anchorEventTag2 = try XCTUnwrap(EventTag(eventId: longformContentEvent.id, relayURL: relayURL))

        let anchorEventAddress1 = try XCTUnwrap(longformContentEvent.replaceableEventCoordinates(relayURL: relayURL))
        let anchorEventAddress2 = try XCTUnwrap(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: relayURL))

        let draftReply = try TextNoteEvent.Builder()
            .content("This is a draft reply!")
            .build(signedBy: .test)

        let draftPrivateWrapEvent = try DraftPrivateWrapEvent.Builder()
            .identifier(identifier)
            .draftEventKind(.textNote)
            .appendAnchorEvents(anchorEventTag1, anchorEventTag2)
            .appendAnchorEventAddresses(anchorEventAddress1, anchorEventAddress2)
            .draftContent(draftReply, encryptedWith: .test)
            .build(signedBy: .test)

        try verifyEvent(draftPrivateWrapEvent)

        XCTAssertEqual(draftPrivateWrapEvent.identifier, identifier)
        XCTAssertEqual(draftPrivateWrapEvent.draftEventKind, .textNote)
        XCTAssertEqual(draftPrivateWrapEvent.anchorEvents, [anchorEventTag1, anchorEventTag2])
        XCTAssertEqual(draftPrivateWrapEvent.anchorEventAddresses, [anchorEventAddress1, anchorEventAddress2])
        XCTAssertFalse(draftPrivateWrapEvent.content.isEmpty)
        XCTAssertEqual(try draftPrivateWrapEvent.draftEvent(decryptedWith: .test), draftReply)
    }

}
