//
//  EventCreatingTests.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation
@testable import NostrSDK
import XCTest

final class EventCreatingTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {
    
    func testCreateSetMetadataEvent() throws {
        let meta = UserMetadata(name: "Nostr SDK Test :ostrich:",
                                displayName: "Nostr SDK Display Name",
                                about: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:",
                                website: URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"),
                                nostrAddress: "test@nostr.com",
                                pictureURL: URL(string: "https://nostrsdk.com/picture.png"),
                                bannerPictureURL: URL(string: "https://nostrsdk.com/banner.png"))

        let ostrichImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        let appleImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/apple.png"))

        let customEmojis = [
            try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: ostrichImageURL)),
            try XCTUnwrap(CustomEmoji(shortcode: "apple", imageURL: appleImageURL))
        ]
        let customEmojiTags = [
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]),
            Tag(name: .emoji, value: "apple", otherParameters: ["https://nostrsdk.com/apple.png"])
        ]

        let event = try setMetadataEvent(withUserMetadata: meta, customEmojis: customEmojis, signedBy: Keypair.test)

        XCTAssertEqual(event.userMetadata?.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.userMetadata?.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.userMetadata?.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.userMetadata?.website, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.userMetadata?.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.userMetadata?.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.userMetadata?.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.customEmojis, customEmojis)
        XCTAssertEqual(event.tags, customEmojiTags)

        try verifyEvent(event)
    }
    
    func testCreateSignedTextNote() throws {
        let imageURLString = "https://nostrsdk.com/ostrich.png"
        let imageURL = try XCTUnwrap(URL(string: imageURLString))
        let customEmoji = try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: imageURL))

        let note = try textNote(withContent: "Hello world! :ostrich:",
                                subject: "test-subject",
                                customEmojis: [customEmoji],
                                signedBy: Keypair.test)

        XCTAssertEqual(note.kind, .textNote)
        XCTAssertEqual(note.content, "Hello world! :ostrich:")
        XCTAssertEqual(note.subject, "test-subject")
        XCTAssertEqual(note.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(note.tags, [Tag(name: .emoji, value: "ostrich", otherParameters: [imageURLString]), Tag(name: .subject, value: "test-subject")])
        XCTAssertEqual(note.customEmojis, [customEmoji])

        try verifyEvent(note)
    }
    
    func testCreateRecommendServerEvent() throws {
        let inputURL = URL(string: "wss://relay.test")!
        let event = try recommendServerEvent(withRelayURL: inputURL,
                                             signedBy: Keypair.test)
        
        XCTAssertEqual(event.kind, .recommendServer)
        XCTAssertEqual(event.relayURL, inputURL)
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.tags, [])
        
        try verifyEvent(event)
    }
    
    func testRecommendServerEventFailsWithNonWebsocketURL() throws {
        let inputURL = URL(string: "https://not-a-socket.com")!
        XCTAssertThrowsError(try recommendServerEvent(withRelayURL: inputURL,
                                                      signedBy: Keypair.test))
    }
    
    func testCreateContactListEvent() throws {
        let pubkeys = [
            "83y9iuhw9u0t8thw8w80u",
            "19048ut34h23y89jio3r8",
            "5r623gyewfbh8uuiq83rd"
        ]
        
        let event = try contactList(withPubkeys: pubkeys,
                                    signedBy: Keypair.test)
        
        let expectedTags: [Tag] = [
            Tag(name: .pubkey, value: "83y9iuhw9u0t8thw8w80u"),
            Tag(name: .pubkey, value: "19048ut34h23y89jio3r8"),
            Tag(name: .pubkey, value: "5r623gyewfbh8uuiq83rd")
        ]
        
        XCTAssertEqual(event.tags, expectedTags)
        
        try verifyEvent(event)
    }
    
    func testCreateContactListEventWithPetnames() throws {
        let tags: [Tag] = [
            Tag(name: .pubkey, value: "83y9iuhw9u0t8thw8w80u", otherParameters: ["bob"]),
            Tag(name: .pubkey, value: "19048ut34h23y89jio3r8", otherParameters: ["alice"]),
            Tag(name: .pubkey, value: "5r623gyewfbh8uuiq83rd", otherParameters: ["steve"])
        ]
        
        let event = try contactList(withPubkeyTags: tags,
                                    signedBy: Keypair.test)
        
        XCTAssertEqual(event.tags, tags)
        
        try verifyEvent(event)
    }
    
    func testDirectMessageEvent() throws {
        let content = "Secret message."
        let recipientPubKey = Keypair.test.publicKey
        let recipientTag = Tag(name: .pubkey, value: recipientPubKey.hex)

        let event = try directMessage(withContent: content, toRecipient: recipientPubKey, signedBy: Keypair.test)

        // Content should contain "?iv=" if encrypted
        XCTAssert(event.content.contains("?iv="))

        // Recipient should be tagged
        let tag = try XCTUnwrap(event.tags.first)
        XCTAssertEqual(tag, recipientTag)

        // Content should be decryptable
        XCTAssertEqual(try event.decryptedContent(using: Keypair.test.privateKey), content)

        try verifyEvent(event)
    }
    
    func testDeletionEvent() throws {
        let noteToDelete: TextNoteEvent = try decodeFixture(filename: "text_note_deletable")
        let reason = "Didn't mean to post"
        
        let event = try delete(events: [noteToDelete], reason: reason, signedBy: Keypair.test)
        
        XCTAssertEqual(event.kind, .deletion)
        
        XCTAssertEqual(event.reason, "Didn't mean to post")
        XCTAssertEqual(event.deletedEventIds, ["fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b"])
        
        try verifyEvent(event)
    }

    func testDeletionEventFailsWithMismatchedKey() throws {
        let noteToDelete: TextNoteEvent = try decodeFixture(filename: "text_note")
        let reason = "Didn't mean to post"
        
        XCTAssertThrowsError(try delete(events: [noteToDelete], reason: reason, signedBy: Keypair.test))
    }
    
    func testRepostTextNoteEvent() throws {
        let noteToRepost: TextNoteEvent = try decodeFixture(filename: "text_note")
        
        let event = try repost(event: noteToRepost, signedBy: Keypair.test)
        let repostEvent = try XCTUnwrap(event as? TextNoteRepostEvent)
        
        XCTAssertEqual(repostEvent.kind, .repost)
        
        XCTAssertTrue(repostEvent.tags.contains(Tag(name: .pubkey, value: "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")))
        XCTAssertTrue(repostEvent.tags.contains(Tag(name: .event, value: "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")))
        
        let repostedNote = try XCTUnwrap(repostEvent.repostedNote)
        XCTAssertEqual(repostedNote.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(repostedNote.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(repostedNote.createdAt, 1682080184)
        
        try verifyEvent(event)
    }
    
    func testCreateReactionEvent() throws {
        let reactedEvent = try textNote(withContent: "Hello world!",
                                signedBy: Keypair.test)
        let event = try reaction(withContent: "🤙",
                                 reactedEvent: reactedEvent,
                                 signedBy: Keypair.test)

        XCTAssertEqual(event.kind, .reaction)
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.reactedEventId, reactedEvent.id)
        XCTAssertEqual(event.reactedEventPubkey, reactedEvent.pubkey)
        XCTAssertEqual(event.content, "🤙")

        let expectedTags = [
            Tag(name: .event, value: reactedEvent.id),
            Tag(name: .pubkey, value: reactedEvent.pubkey)
        ]
        XCTAssertEqual(event.tags, expectedTags)

        try verifyEvent(event)
    }

    func testCreateCustomEmojiReactionEvent() throws {
        let reactedEvent = try textNote(withContent: "Hello world!",
                                signedBy: Keypair.test)

        let imageURLString = "https://nostrsdk.com/ostrich.png"
        let imageURL = try XCTUnwrap(URL(string: imageURLString))
        let customEmoji = try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: imageURL))
        let event = try reaction(withCustomEmoji: customEmoji,
                                 reactedEvent: reactedEvent,
                                 signedBy: Keypair.test)

        XCTAssertEqual(event.kind, .reaction)
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.reactedEventId, reactedEvent.id)
        XCTAssertEqual(event.reactedEventPubkey, reactedEvent.pubkey)
        XCTAssertEqual(event.content, ":ostrich:")
        XCTAssertEqual(event.customEmojis, [customEmoji])

        let expectedTags = [
            Tag(name: .event, value: reactedEvent.id),
            Tag(name: .pubkey, value: reactedEvent.pubkey),
            Tag(name: .emoji, value: "ostrich", otherParameters: [imageURLString])
        ]
        XCTAssertEqual(event.tags, expectedTags)

        try verifyEvent(event)
    }

    func testRepostNonTextNoteEvent() throws {
        let eventToRepost: RecommendServerEvent = try decodeFixture(filename: "recommend_server")
        
        let repostEvent = try repost(event: eventToRepost, signedBy: Keypair.test)
        XCTAssertFalse(repostEvent is TextNoteRepostEvent)
        XCTAssertEqual(repostEvent.kind, .genericRepost)
        
        XCTAssertTrue(repostEvent.tags.contains(Tag(name: .pubkey, value: "test-pubkey")))
        XCTAssertTrue(repostEvent.tags.contains(Tag(name: .event, value: "test-id")))
        XCTAssertTrue(repostEvent.tags.contains(Tag(name: .kind, value: "2")))
        
        let repostedEvent = try XCTUnwrap(repostEvent.repostedEvent)
        XCTAssertEqual(repostedEvent.id, "test-id")
        XCTAssertEqual(repostedEvent.pubkey, "test-pubkey")
        XCTAssertEqual(repostedEvent.createdAt, 1683799330)
        
        try verifyEvent(repostEvent)
    }
    
    func testReportUser() throws {
        let report = try reportUser(withPublicKey: Keypair.test.publicKey, reportType: .impersonation, additionalInformation: "he's lying!", signedBy: Keypair.test)
        
        XCTAssertEqual(report.kind, .report)
        XCTAssertEqual(report.content, "he's lying!")
        
        let expectedTag = Tag(name: .pubkey, value: Keypair.test.publicKey.hex, otherParameters: ["impersonation"])
        XCTAssertTrue(report.tags.contains(expectedTag))
        
        try verifyEvent(report)
    }
    
    func testReportNote() throws {
        let noteToReport: TextNoteEvent = try decodeFixture(filename: "text_note")
        
        let report = try reportNote(noteToReport, reportType: .profanity, additionalInformation: "mean words", signedBy: Keypair.test)
        
        XCTAssertEqual(report.kind, .report)
        XCTAssertEqual(report.content, "mean words")
        
        let expectedPubkeyTag = Tag(name: .pubkey, value: "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertTrue(report.tags.contains(expectedPubkeyTag))
        
        let expectedEventTag = Tag(name: .event, value: noteToReport.id, otherParameters: ["profanity"])
        XCTAssertTrue(report.tags.contains(expectedEventTag))
        
        try verifyEvent(report)
    }
    
    func testReportNoteWithImpersonationShouldFail() throws {
        let noteToReport: TextNoteEvent = try decodeFixture(filename: "text_note")
        
        XCTAssertThrowsError(try reportNote(noteToReport, reportType: .impersonation, additionalInformation: "mean words", signedBy: Keypair.test))
    }

    func testDateBasedCalendarEvent() throws {
        let name = "Nostrica"
        let description = "First Nostr unconference"

        let calendar = Calendar(identifier: .iso8601)
        let startComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 19)
        let endComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 21)

        let location = "Awake, C. Garcias, Provincia de Puntarenas, Uvita, 60504, Costa Rica"
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
            withName: name,
            description: description,
            startComponents: startComponents,
            endComponents: endComponents,
            location: location,
            geohash: geohash,
            participants: participants,
            hashtags: hashtags,
            references: references,
            signedBy: Keypair.test
        )

        XCTAssertEqual(dateBasedCalendarEvent.name, name)
        XCTAssertEqual(dateBasedCalendarEvent.content, description)
        XCTAssertEqual(dateBasedCalendarEvent.start, startComponents)
        XCTAssertEqual(dateBasedCalendarEvent.end, endComponents)
        XCTAssertEqual(dateBasedCalendarEvent.location, location)
        XCTAssertEqual(dateBasedCalendarEvent.geohash, geohash)
        XCTAssertEqual(dateBasedCalendarEvent.participants, participants)
        XCTAssertEqual(dateBasedCalendarEvent.hashtags, hashtags)
        XCTAssertEqual(dateBasedCalendarEvent.references, references)

        try verifyEvent(dateBasedCalendarEvent)
    }

    func testDateBasedCalendarEventWithStartDateSameAsEndDateShouldFail() throws {
        let name = "Nostrica"
        let description = "First Nostr unconference"
        let calendar = Calendar(identifier: .iso8601)
        let dateComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 19)

        XCTAssertThrowsError(try dateBasedCalendarEvent(withName: name, description: description, startComponents: dateComponents, endComponents: dateComponents, signedBy: Keypair.test))
    }

    func testDateBasedCalendarEventWithEndDateBeforeStartDateShouldFail() throws {
        let name = "Nostrica"
        let description = "First Nostr unconference"
        let calendar = Calendar(identifier: .iso8601)
        let startComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 19)
        let endComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 18)

        XCTAssertThrowsError(try dateBasedCalendarEvent(withName: name, description: description, startComponents: startComponents, endComponents: endComponents, signedBy: Keypair.test))
    }

    func testDateBasedCalendarEventWithInvalidStartDateShouldFail() throws {
        let name = "Nostrica"
        let description = "First Nostr unconference"
        let calendar = Calendar(identifier: .iso8601)
        let startComponents = DateComponents(calendar: calendar, year: 2023, month: 2, day: 31)
        let endComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 21)

        XCTAssertThrowsError(try dateBasedCalendarEvent(withName: name, description: description, startComponents: startComponents, endComponents: endComponents, signedBy: Keypair.test))
    }

    func testDateBasedCalendarEventWithInvalidEndDateShouldFail() throws {
        let name = "Nostrica"
        let description = "First Nostr unconference"
        let calendar = Calendar(identifier: .iso8601)
        let startComponents = DateComponents(calendar: calendar, year: 2023, month: 2, day: 19)
        let endComponents = DateComponents(calendar: calendar, year: 2023, month: 2, day: 31)

        XCTAssertThrowsError(try dateBasedCalendarEvent(withName: name, description: description, startComponents: startComponents, endComponents: endComponents, signedBy: Keypair.test))
    }

    func testTimeBasedCalendarEvent() throws {
        let name = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)

        let endTimeZone = TimeZone(identifier: "America/Costa_Rica")
        let endComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: endTimeZone, year: 2023, month: 3, day: 17, hour: 11, minute: 42)

        let start = try XCTUnwrap(startComponents.date)
        let end = try XCTUnwrap(endComponents.date)

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
            withName: name,
            description: description,
            start: start,
            end: end,
            startTimeZone: startTimeZone,
            endTimeZone: endTimeZone,
            location: location,
            geohash: geohash,
            participants: participants,
            hashtags: hashtags,
            references: references,
            signedBy: Keypair.test
        )

        XCTAssertEqual(timeBasedCalendarEvent.name, name)
        XCTAssertEqual(timeBasedCalendarEvent.content, description)
        XCTAssertEqual(timeBasedCalendarEvent.start, start)
        XCTAssertEqual(timeBasedCalendarEvent.end, end)
        XCTAssertEqual(timeBasedCalendarEvent.startTimeZone, startTimeZone)
        XCTAssertEqual(timeBasedCalendarEvent.endTimeZone, endTimeZone)
        XCTAssertEqual(timeBasedCalendarEvent.location, location)
        XCTAssertEqual(timeBasedCalendarEvent.geohash, geohash)
        XCTAssertEqual(timeBasedCalendarEvent.participants, participants)
        XCTAssertEqual(timeBasedCalendarEvent.hashtags, hashtags)
        XCTAssertEqual(timeBasedCalendarEvent.references, references)

        try verifyEvent(timeBasedCalendarEvent)
    }

    func testTimeBasedCalendarEventWithStartTimestampSameAsEndTimestampShouldFail() throws {
        let name = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let timeZone = TimeZone(identifier: "America/New_York")
        let dateComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)
        let timestamp = try XCTUnwrap(dateComponents.date)

        XCTAssertThrowsError(try timeBasedCalendarEvent(withName: name, description: description, start: timestamp, end: timestamp, signedBy: Keypair.test))
    }

    func testTimeBasedCalendarEventWithEndTimestampBeforeStartTimestampShouldFail() throws {
        let name = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let timeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)
        let endComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 14)

        let start = try XCTUnwrap(startComponents.date)
        let end = try XCTUnwrap(endComponents.date)

        XCTAssertThrowsError(try timeBasedCalendarEvent(withName: name, description: description, start: start, end: end, signedBy: Keypair.test))
    }
}
