//
//  DateBasedCalendarEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class DateBasedCalendarEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateDateBasedCalendarEvent() throws {
        let identifier = "nostrica-12345"
        let title = "Nostrica"
        let summary = "First Nostr unconference summary"
        let imageString = "https://nostrsdk.com/image.png"
        let description = "First Nostr unconference description"

        let startDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 19))
        let endDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 21))

        let locations = ["Awake, C. Garcias, Provincia de Puntarenas, Uvita, 60504, Costa Rica", "YouTube"]
        let geohash = "d1sknt77t3xn"

        let relayURL = try XCTUnwrap(URL(string: "wss://relay.nostrsdk.com"))
        let participant1 = try XCTUnwrap(CalendarEventParticipant(pubkey: Keypair.test.publicKey, relayURL: relayURL, role: "organizer"))
        let participant2 = try XCTUnwrap(CalendarEventParticipant(pubkey: Keypair.test.publicKey, relayURL: relayURL, role: "attendee"))
        let participants = [participant1, participant2]

        let hashtags = ["nostr", "unconference", "nostrica"]
        let reference1 = try XCTUnwrap(URL(string: "https://nostrica.com/"))
        let reference2 = try XCTUnwrap(URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit"))
        let references = [reference1, reference2]

        let dateBasedCalendarEvent = try dateBasedCalendarEvent(
            withIdentifier: identifier,
            title: title,
            summary: summary,
            imageURL: URL(string: imageString),
            description: description,
            startDate: startDate,
            endDate: endDate,
            locations: locations,
            geohash: geohash,
            participants: participants,
            hashtags: hashtags,
            references: references,
            signedBy: Keypair.test
        )

        XCTAssertEqual(dateBasedCalendarEvent.identifier, identifier)
        XCTAssertEqual(dateBasedCalendarEvent.title, title)
        XCTAssertEqual(dateBasedCalendarEvent.summary, summary)
        XCTAssertEqual(dateBasedCalendarEvent.imageURL?.absoluteString, imageString)
        XCTAssertEqual(dateBasedCalendarEvent.content, description)
        XCTAssertEqual(dateBasedCalendarEvent.startDate, startDate)
        XCTAssertEqual(dateBasedCalendarEvent.endDate, endDate)
        XCTAssertEqual(dateBasedCalendarEvent.locations, locations)
        XCTAssertEqual(dateBasedCalendarEvent.geohash, geohash)
        XCTAssertEqual(dateBasedCalendarEvent.participants, participants)
        XCTAssertEqual(dateBasedCalendarEvent.hashtags, hashtags)
        XCTAssertEqual(dateBasedCalendarEvent.references, references)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .dateBasedCalendarEvent, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(dateBasedCalendarEvent.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(dateBasedCalendarEvent)
    }

    func testCreateDateBasedCalendarEventWithStartDateSameAsEndDateShouldFail() throws {
        let title = "Nostrica"
        let description = "First Nostr unconference"
        let timeOmittedDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 19))

        XCTAssertThrowsError(try dateBasedCalendarEvent(title: title, description: description, startDate: timeOmittedDate, endDate: timeOmittedDate, signedBy: Keypair.test))
    }

    func testCreateDateBasedCalendarEventWithEndDateBeforeStartDateShouldFail() throws {
        let title = "Nostrica"
        let description = "First Nostr unconference"
        let startDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 19))
        let endDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 18))

        XCTAssertThrowsError(try dateBasedCalendarEvent(title: title, description: description, startDate: startDate, endDate: endDate, signedBy: Keypair.test))
    }

    func testDecodeDateBasedCalendarEvent() throws {
        let event: DateBasedCalendarEvent = try decodeFixture(filename: "date_based_calendar_event")

        XCTAssertEqual(event.id, "a87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171d")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702832309)
        XCTAssertEqual(event.kind, .dateBasedCalendarEvent)
        XCTAssertEqual(event.identifier, "06E43CF4-D253-4AF9-807A-96FDA4763FF4")
        XCTAssertEqual(event.title, "Nostrica")
        XCTAssertEqual(event.startDate, TimeOmittedDate(year: 2023, month: 3, day: 19))
        XCTAssertEqual(event.endDate, TimeOmittedDate(year: 2023, month: 3, day: 21))
        XCTAssertEqual(event.locations, ["Awake, C. Garcias, Provincia de Puntarenas, Uvita, 60504, Costa Rica", "YouTube"])
        XCTAssertEqual(event.geohash, "d1sknt77t3xn")

        let participants = event.participants
        let expectedParticipantPublicKey = Keypair.test.publicKey
        let relayURL = URL(string: "wss://relay.nostrsdk.com")
        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants,
                       [CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "organizer"),
                        CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "attendee")])

        XCTAssertEqual(event.hashtags, ["nostr", "unconference", "nostrica"])

        XCTAssertEqual(event.references, [URL(string: "https://nostrica.com/"), URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit")])

        XCTAssertEqual(event.content, "First Nostr unconference")
        XCTAssertEqual(event.signature, "b1f04510811195f69552dc1aff5033f306b4fdf9e6e7c1ac265438b457932266414bdf1ed9ec0c2c2f22d56bef7e519af5c3bfb974c933fd20037918b95dc65a")
    }

}
