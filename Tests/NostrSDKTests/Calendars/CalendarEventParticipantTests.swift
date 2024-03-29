//
//  CalendarEventParticipantTests.swift
//  
//
//  Created by Terry Yiu on 11/16/23.
//

import XCTest
@testable import NostrSDK

final class CalendarEventParticipantTests: XCTestCase {

    func testCalendarEventParticipant() throws {
        let pubkey = Keypair.test.publicKey
        let relay = "wss://relay.nostrsdk.com"
        let role = "organizer"
        let tag = Tag.pubkey(pubkey.hex, otherParameters: [relay, role])
        let calendarEventParticipant = try XCTUnwrap(CalendarEventParticipant(pubkeyTag: tag))

        XCTAssertEqual(calendarEventParticipant.pubkey, pubkey)
        XCTAssertEqual(calendarEventParticipant.relayURL?.absoluteString, relay)
        XCTAssertEqual(calendarEventParticipant.role, role)
        XCTAssertEqual(calendarEventParticipant.tag, tag)
    }

}
