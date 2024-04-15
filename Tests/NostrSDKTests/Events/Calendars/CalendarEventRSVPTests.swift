//
//  CalendarEventRSVPTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class CalendarEventRSVPTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateDateBasedCalendarEventRSVP() throws {
        let timeOmittedStartDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 12, day: 31))
        let dateBasedCalendarEvent = try XCTUnwrap(dateBasedCalendarEvent(title: "New Year's Eve", startDate: timeOmittedStartDate, signedBy: Keypair.test))
        let dateBasedCalendarEventCoordinates = try XCTUnwrap(dateBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil))

        let identifier = "hockey-practice-rsvp"
        let note = "Don't forget your skates!"
        let calendarEventRSVP = try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: dateBasedCalendarEventCoordinates, status: .accepted, freebusy: .busy, note: note, signedBy: Keypair.test)

        XCTAssertEqual(calendarEventRSVP.identifier, identifier)
        XCTAssertEqual(calendarEventRSVP.calendarEventCoordinates, dateBasedCalendarEventCoordinates)
        XCTAssertEqual(calendarEventRSVP.status, .accepted)
        XCTAssertEqual(calendarEventRSVP.freebusy, .busy)
        XCTAssertEqual(calendarEventRSVP.content, note)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .calendarEventRSVP, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(calendarEventRSVP.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(calendarEventRSVP)
    }

    func testCreateTimeBasedCalendarEventRSVP() throws {
        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil))

        let identifier = "hockey-practice-rsvp"
        let note = "Don't forget your skates!"
        let calendarEventRSVP = try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: timeBasedCalendarEventCoordinates, status: .accepted, freebusy: .busy, note: note, signedBy: Keypair.test)

        XCTAssertEqual(calendarEventRSVP.identifier, identifier)
        XCTAssertEqual(calendarEventRSVP.calendarEventCoordinates, timeBasedCalendarEventCoordinates)
        XCTAssertEqual(calendarEventRSVP.status, .accepted)
        XCTAssertEqual(calendarEventRSVP.freebusy, .busy)
        XCTAssertEqual(calendarEventRSVP.content, note)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .calendarEventRSVP, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(calendarEventRSVP.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(calendarEventRSVP)
    }

    func testCreateCalendarEventRSVPWithInvalidCalendarEventCoordinatesShouldFail() throws {
        let identifier = "hockey-practice-rsvp"
        let note = "Don't forget your skates!"
        let eventCoordinates = try XCTUnwrap(EventCoordinates(kind: .longformContent, pubkey: Keypair.test.publicKey, identifier: "abc"))

        XCTAssertThrowsError(try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: eventCoordinates, status: .accepted, freebusy: .busy, note: note, signedBy: Keypair.test))
    }

    func testCreateCalendarEventRSVPWithDeclineAndNoFreebusy() throws {
        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil))

        let identifier = "hockey-practice-rsvp"
        let calendarEventRSVP = try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: timeBasedCalendarEventCoordinates, status: .declined, signedBy: Keypair.test)

        XCTAssertEqual(calendarEventRSVP.identifier, identifier)
        XCTAssertEqual(calendarEventRSVP.calendarEventCoordinates, timeBasedCalendarEventCoordinates)
        XCTAssertEqual(calendarEventRSVP.status, .declined)
        XCTAssertNil(calendarEventRSVP.freebusy)

        try verifyEvent(calendarEventRSVP)
    }

    func testCreateCalendarEventRSVPWithDeclineAndFreebusyShouldFail() throws {
        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil))

        let identifier = "hockey-practice-rsvp"
        XCTAssertThrowsError(try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: timeBasedCalendarEventCoordinates, status: .declined, freebusy: .busy, signedBy: Keypair.test))
    }

    func testDecodeCalendarEventRSVP() throws {
        let event: CalendarEventRSVP = try decodeFixture(filename: "calendar_event_rsvp")

        XCTAssertEqual(event.id, "1ec761bbeacd17f4ca961668725ea85a9001a0f56da37eb424856a9de1188a2d")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .calendarEventRSVP)
        XCTAssertEqual(event.signature, "21c58b1d759c6470cbb1931653d3c44cbc24c87be9632b794b2c4bb3a0abd27117dd9e3c8c90cf669a6f0d8204f20f92c2a20ed832a54d999d010402d2b1aa9a")
        XCTAssertEqual(event.createdAt, 1703052002)
        XCTAssertEqual(event.content, "Don't forget your skates!")
        XCTAssertEqual(event.identifier, "hockey-practice-rsvp")
        XCTAssertEqual(event.status, .accepted)
        XCTAssertEqual(event.freebusy, .busy)

        let pubkey = try XCTUnwrap(PublicKey(hex: "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"))
        let dateBasedCalendarEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .dateBasedCalendarEvent, pubkey: pubkey, identifier: "D1D48740-2CF8-4483-B5F0-1E83F6D7EC50"))

        XCTAssertEqual(event.calendarEventCoordinates, dateBasedCalendarEventCoordinates)
    }

}
