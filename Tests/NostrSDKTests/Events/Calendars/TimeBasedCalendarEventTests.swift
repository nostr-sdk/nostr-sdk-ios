//
//  TimeBasedCalendarEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class TimeBasedCalendarEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateTimeBasedCalendarEvent() throws {
        let identifier = "flight-from-new-york-jfk-to-san-jose-costa-rica-sjo-12345"
        let title = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let startTimeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)

        let endTimeZone = try XCTUnwrap(TimeZone(identifier: "America/Costa_Rica"))
        let endComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: endTimeZone, year: 2023, month: 3, day: 17, hour: 11, minute: 42)

        let startTimestamp = try XCTUnwrap(startComponents.date)
        let endTimestamp = try XCTUnwrap(endComponents.date)

        let location = "John F. Kennedy International Airport, Queens, NY 11430, USA"
        let geohash = "dr5x1p57bg9e"

        let relayURL = try XCTUnwrap(URL(string: "wss://relay.nostrsdk.com"))
        let participant1 = try XCTUnwrap(CalendarEventParticipant(pubkey: Keypair.test.publicKey, relayURL: relayURL, role: "organizer"))
        let participant2 = try XCTUnwrap(CalendarEventParticipant(pubkey: Keypair.test.publicKey, relayURL: relayURL, role: "attendee"))
        let participants = [participant1, participant2]

        let hashtags = ["flights", "costarica"]
        let reference1 = try XCTUnwrap(URL(string: "https://nostrica.com/"))
        let reference2 = try XCTUnwrap(URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit"))
        let references = [reference1, reference2]

        let timeBasedCalendarEvent = try TimeBasedCalendarEvent.Builder()
            .identifier(identifier)
            .title(title)
            .description(description)
            .timestamps(from: startTimestamp, to: endTimestamp)
            .startTimeZone(startTimeZone)
            .endTimeZone(endTimeZone)
            .locations([location])
            .geohash(geohash)
            .participants(participants)
            .hashtags(hashtags)
            .references(references)
            .build(signedBy: .test)

        XCTAssertEqual(timeBasedCalendarEvent.identifier, identifier)
        XCTAssertEqual(timeBasedCalendarEvent.title, title)
        XCTAssertEqual(timeBasedCalendarEvent.content, description)
        XCTAssertEqual(timeBasedCalendarEvent.startTimestamp, startTimestamp)
        XCTAssertEqual(timeBasedCalendarEvent.endTimestamp, endTimestamp)
        XCTAssertEqual(timeBasedCalendarEvent.startTimeZone, startTimeZone)
        XCTAssertEqual(timeBasedCalendarEvent.endTimeZone, endTimeZone)
        XCTAssertEqual(timeBasedCalendarEvent.locations, [location])
        XCTAssertEqual(timeBasedCalendarEvent.geohash, geohash)
        XCTAssertEqual(timeBasedCalendarEvent.participants, participants)
        XCTAssertEqual(timeBasedCalendarEvent.hashtags, hashtags)
        XCTAssertEqual(timeBasedCalendarEvent.references, references)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .timeBasedCalendarEvent, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(timeBasedCalendarEvent)
    }

    func testCreateTimeBasedCalendarEventDeprecated() throws {
        let identifier = "flight-from-new-york-jfk-to-san-jose-costa-rica-sjo-12345"
        let title = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)

        let endTimeZone = TimeZone(identifier: "America/Costa_Rica")
        let endComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: endTimeZone, year: 2023, month: 3, day: 17, hour: 11, minute: 42)

        let startTimestamp = try XCTUnwrap(startComponents.date)
        let endTimestamp = try XCTUnwrap(endComponents.date)

        let location = "John F. Kennedy International Airport, Queens, NY 11430, USA"
        let geohash = "dr5x1p57bg9e"

        let relayURL = try XCTUnwrap(URL(string: "wss://relay.nostrsdk.com"))
        let participant1 = try XCTUnwrap(CalendarEventParticipant(pubkey: Keypair.test.publicKey, relayURL: relayURL, role: "organizer"))
        let participant2 = try XCTUnwrap(CalendarEventParticipant(pubkey: Keypair.test.publicKey, relayURL: relayURL, role: "attendee"))
        let participants = [participant1, participant2]

        let hashtags = ["flights", "costarica"]
        let reference1 = try XCTUnwrap(URL(string: "https://nostrica.com/"))
        let reference2 = try XCTUnwrap(URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit"))
        let references = [reference1, reference2]

        let timeBasedCalendarEvent = try timeBasedCalendarEvent(
            withIdentifier: identifier,
            title: title,
            description: description,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            startTimeZone: startTimeZone,
            endTimeZone: endTimeZone,
            locations: [location],
            geohash: geohash,
            participants: participants,
            hashtags: hashtags,
            references: references,
            signedBy: Keypair.test
        )

        XCTAssertEqual(timeBasedCalendarEvent.identifier, identifier)
        XCTAssertEqual(timeBasedCalendarEvent.title, title)
        XCTAssertEqual(timeBasedCalendarEvent.content, description)
        XCTAssertEqual(timeBasedCalendarEvent.startTimestamp, startTimestamp)
        XCTAssertEqual(timeBasedCalendarEvent.endTimestamp, endTimestamp)
        XCTAssertEqual(timeBasedCalendarEvent.startTimeZone, startTimeZone)
        XCTAssertEqual(timeBasedCalendarEvent.endTimeZone, endTimeZone)
        XCTAssertEqual(timeBasedCalendarEvent.locations, [location])
        XCTAssertEqual(timeBasedCalendarEvent.geohash, geohash)
        XCTAssertEqual(timeBasedCalendarEvent.participants, participants)
        XCTAssertEqual(timeBasedCalendarEvent.hashtags, hashtags)
        XCTAssertEqual(timeBasedCalendarEvent.references, references)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .timeBasedCalendarEvent, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(timeBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(timeBasedCalendarEvent)
    }

    func testCreateTimeBasedCalendarEventWithStartTimestampSameAsEndTimestampShouldFail() throws {
        let title = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let timeZone = TimeZone(identifier: "America/New_York")
        let dateComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)
        let timestamp = try XCTUnwrap(dateComponents.date)

        XCTAssertThrowsError(try TimeBasedCalendarEvent.Builder().timestamps(from: timestamp, to: timestamp))
    }

    func testCreateTimeBasedCalendarEventWithEndTimestampBeforeStartTimestampShouldFail() throws {
        let title = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let timeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)
        let endComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 14)

        let startTimestamp = try XCTUnwrap(startComponents.date)
        let endTimestamp = try XCTUnwrap(endComponents.date)

        XCTAssertThrowsError(try TimeBasedCalendarEvent.Builder().timestamps(from: startTimestamp, to: endTimestamp))
    }

    func testDecodeTimeBasedCalendarEvent() throws {
        let event: TimeBasedCalendarEvent = try decodeFixture(filename: "time_based_calendar_event")

        XCTAssertEqual(event.id, "818854c3ff09ac5a2c538cba81d911e59f929dcc5531f61ac92278093d101f1b")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702833417)
        XCTAssertEqual(event.kind, .timeBasedCalendarEvent)
        XCTAssertEqual(event.identifier, "798F1F69-1DE3-4623-8DCC-FAF9B773E72B")
        XCTAssertEqual(event.title, "Flight from New York (JFK) to San José, Costa Rica (SJO)")
        XCTAssertEqual(event.startTimestamp, Date(timeIntervalSince1970: 1679062500))
        XCTAssertEqual(event.endTimestamp, Date(timeIntervalSince1970: 1679067720))
        XCTAssertEqual(event.startTimeZone, TimeZone(identifier: "America/New_York"))
        XCTAssertEqual(event.endTimeZone, TimeZone(identifier: "America/Costa_Rica"))
        XCTAssertEqual(event.locations, ["John F. Kennedy International Airport, Queens, NY 11430, USA"])
        XCTAssertEqual(event.geohash, "dr5x1p57bg9e")

        let participants = event.participants
        let expectedParticipantPublicKey = Keypair.test.publicKey
        let relayURL = URL(string: "wss://relay.nostrsdk.com")
        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants,
                       [CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "organizer"),
                        CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "attendee")])

        XCTAssertEqual(event.hashtags, ["flights", "costarica"])

        XCTAssertEqual(event.references, [URL(string: "https://nostrica.com/"), URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit")])

        XCTAssertEqual(event.content, "Flight to Nostrica")
        XCTAssertEqual(event.signature, "c2aa36b07c4df050d637dd2be770767c67621e7d87179f9f1e5ef118543328ed238afbd6b33317a61178205b75e6ecb0a61ea4cf6c657a7da0e4cea4842d4c01")
    }

}
