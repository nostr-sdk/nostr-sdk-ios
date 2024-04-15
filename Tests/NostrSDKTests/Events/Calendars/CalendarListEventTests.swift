//
//  CalendarListEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class CalendarListEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateCalendarListEvent() throws {
        let timeOmittedStartDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 12, day: 31))
        let dateBasedCalendarEvent = try XCTUnwrap(dateBasedCalendarEvent(title: "New Year's Eve", startDate: timeOmittedStartDate, signedBy: Keypair.test))
        let dateBasedCalendarEventCoordinates = try XCTUnwrap(dateBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil))

        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil))

        let identifier = "family-calendar"
        let title = "Family Calendar"
        let description = "All family events."
        let calendar = try calendarListEvent(withIdentifier: identifier, title: title, description: description, calendarEventsCoordinates: [dateBasedCalendarEventCoordinates, timeBasedCalendarEventCoordinates], signedBy: Keypair.test)

        XCTAssertEqual(calendar.identifier, identifier)
        XCTAssertEqual(calendar.title, title)
        XCTAssertEqual(calendar.content, description)
        XCTAssertEqual(calendar.calendarEventCoordinateList, [dateBasedCalendarEventCoordinates, timeBasedCalendarEventCoordinates])

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .calendar, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(calendar.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(calendar)
    }

    func testCreateCalendarListEventWithNoCalendarEventCoordinates() throws {
        let identifier = "family-calendar"
        let title = "Family Calendar"
        let description = "All family events."
        let calendar = try calendarListEvent(withIdentifier: identifier, title: title, description: description, calendarEventsCoordinates: [], signedBy: Keypair.test)

        XCTAssertEqual(calendar.identifier, identifier)
        XCTAssertEqual(calendar.title, title)
        XCTAssertEqual(calendar.content, description)
        XCTAssertEqual(calendar.calendarEventCoordinateList, [])

        try verifyEvent(calendar)
    }

    func testCreateCalendarListEventWithInvalidCalendarEventCoordinatesShouldFail() throws {
        let identifier = "family-calendar"
        let title = "Family Calendar"
        let description = "All family events."
        let eventCoordinates = try XCTUnwrap(EventCoordinates(kind: .longformContent, pubkey: Keypair.test.publicKey, identifier: "abc"))

        XCTAssertThrowsError(try calendarListEvent(withIdentifier: identifier, title: title, description: description, calendarEventsCoordinates: [eventCoordinates], signedBy: Keypair.test))
    }

    func testDecodeCalendarListEvent() throws {
        let event: CalendarListEvent = try decodeFixture(filename: "calendar")

        XCTAssertEqual(event.id, "1dc8b913d9d4f50a71182dc9232996d6fbc69e8c955866e43ef2c2e35185bbfa")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .calendar)
        XCTAssertEqual(event.signature, "24c397594fe6d8b5590ce4e7163990f4269bc515d1181487d722730144ac32e8439954d66e88f3232ad807e8d06f01791b5856ae249b139b1469df58045252a9")
        XCTAssertEqual(event.createdAt, 1703052671)
        XCTAssertEqual(event.identifier, "family-calendar")
        XCTAssertEqual(event.title, "Family Calendar")
        XCTAssertEqual(event.content, "All family events.")

        let pubkey = try XCTUnwrap(PublicKey(hex: "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"))
        let dateBasedCalendarEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .dateBasedCalendarEvent, pubkey: pubkey, identifier: "D5EB0A5A-0B36-44DB-95C3-DB51799894E6"))
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .timeBasedCalendarEvent, pubkey: pubkey, identifier: "1D355ED3-A45D-41A9-B3A5-709211794EFB"))

        XCTAssertEqual(
            event.calendarEventCoordinateList,
            [
                dateBasedCalendarEventCoordinates,
                timeBasedCalendarEventCoordinates
            ]
        )
    }

}
