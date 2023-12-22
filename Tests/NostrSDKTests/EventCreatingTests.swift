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
            .pubkey("83y9iuhw9u0t8thw8w80u"),
            .pubkey("19048ut34h23y89jio3r8"),
            .pubkey("5r623gyewfbh8uuiq83rd")
        ]
        
        XCTAssertEqual(event.tags, expectedTags)
        
        try verifyEvent(event)
    }
    
    func testCreateContactListEventWithPetnames() throws {
        let tags: [Tag] = [
            .pubkey("83y9iuhw9u0t8thw8w80u", otherParameters: ["bob"]),
            .pubkey("19048ut34h23y89jio3r8", otherParameters: ["alice"]),
            .pubkey("5r623gyewfbh8uuiq83rd", otherParameters: ["steve"])
        ]
        
        let event = try contactList(withPubkeyTags: tags,
                                    signedBy: Keypair.test)
        
        XCTAssertEqual(event.tags, tags)
        
        try verifyEvent(event)
    }
    
    func testDirectMessageEvent() throws {
        let content = "Secret message."
        let recipientPubKey = Keypair.test.publicKey
        let recipientTag = Tag.pubkey(recipientPubKey.hex)

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
        
        XCTAssertTrue(repostEvent.tags.contains(.pubkey("82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")))
        XCTAssertTrue(repostEvent.tags.contains(.event("fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")))
        
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

        let expectedTags: [Tag] = [
            .event(reactedEvent.id),
            .pubkey(reactedEvent.pubkey)
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

        let expectedTags: [Tag] = [
            .event(reactedEvent.id),
            .pubkey(reactedEvent.pubkey),
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
        
        XCTAssertTrue(repostEvent.tags.contains(.pubkey("test-pubkey")))
        XCTAssertTrue(repostEvent.tags.contains(.event("test-id")))
        XCTAssertTrue(repostEvent.tags.contains(.kind(.recommendServer)))
        
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
        
        let expectedTag = Tag.pubkey(Keypair.test.publicKey.hex, otherParameters: ["impersonation"])
        XCTAssertTrue(report.tags.contains(expectedTag))
        
        try verifyEvent(report)
    }
    
    func testReportNote() throws {
        let noteToReport: TextNoteEvent = try decodeFixture(filename: "text_note")
        
        let report = try reportNote(noteToReport, reportType: .profanity, additionalInformation: "mean words", signedBy: Keypair.test)
        
        XCTAssertEqual(report.kind, .report)
        XCTAssertEqual(report.content, "mean words")
        
        let expectedPubkeyTag = Tag.pubkey("82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertTrue(report.tags.contains(expectedPubkeyTag))
        
        let expectedEventTag = Tag.event(noteToReport.id, otherParameters: ["profanity"])
        XCTAssertTrue(report.tags.contains(expectedEventTag))
        
        try verifyEvent(report)
    }
    
    func testReportNoteWithImpersonationShouldFail() throws {
        let noteToReport: TextNoteEvent = try decodeFixture(filename: "text_note")
        
        XCTAssertThrowsError(try reportNote(noteToReport, reportType: .impersonation, additionalInformation: "mean words", signedBy: Keypair.test))
    }
    
    func testMuteListEvent() throws {
        let mutedPubkeys = [
            "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2",
            "72341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"
        ]
        
        let privatelyMutedPubkeys = [
            "52341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2",
            "42341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"
        ]
        
        let mutedEventIds = [
            "964880cab60cab8e510b21714f93b45a288261c49b9a5413f18f69105824410a",
            "05759f0b085181cce6f9784125ca46b71cebbfb6963f029c45e679c9eff6e46f"
        ]
        
        let privatelyMutedEventIds = [
            "761563ea69f4f07539d06a9f78c31c910e82044db8707dab5b8c7ab3b2d00153",
            "7c77d79c2780a074aa26891faf44d9bc1d61fb75813bb2ee9b71d787f34d6a1a"
        ]
        
        let mutedHashtags = [
            "politics",
            "religion"
        ]
        
        let privatelyMutedHashtags = [
            "left",
            "right"
        ]
        
        let mutedKeywords = [
            "sportsball",
            "pokemon"
        ]
        
        let privatelyMutedKeywords = [
            "up",
            "down"
        ]
        
        let event = try muteList(withPubliclyMutedPubkeys: mutedPubkeys,
                                 privatelyMutedPubkeys: privatelyMutedPubkeys,
                                 publiclyMutedEventIds: mutedEventIds,
                                 privatelyMutedEventIds: privatelyMutedEventIds,
                                 publiclyMutedHashtags: mutedHashtags,
                                 privatelyMutedHashtags: privatelyMutedHashtags,
                                 publiclyMutedKeywords: mutedKeywords,
                                 privatelyMutedKeywords: privatelyMutedKeywords,
                                 signedBy: Keypair.test)
        
        // check public tags
        let expectedTags: [Tag] = [
            .pubkey("82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"),
            .pubkey("72341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"),
            .event("964880cab60cab8e510b21714f93b45a288261c49b9a5413f18f69105824410a"),
            .event("05759f0b085181cce6f9784125ca46b71cebbfb6963f029c45e679c9eff6e46f"),
            .hashtag("politics"),
            .hashtag("religion"),
            Tag(name: .word, value: "sportsball"),
            Tag(name: .word, value: "pokemon")
        ]
        
        XCTAssertEqual(event.tags, expectedTags)
        
        XCTAssertEqual(event.pubkeys, mutedPubkeys)
        XCTAssertEqual(event.eventIds, mutedEventIds)
        XCTAssertEqual(event.hashtags, mutedHashtags)
        XCTAssertEqual(event.keywords, mutedKeywords)
        
        // check private tags
        let expectedPrivateTags: [Tag] = [
            .pubkey("52341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"),
            .pubkey("42341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2"),
            .event("761563ea69f4f07539d06a9f78c31c910e82044db8707dab5b8c7ab3b2d00153"),
            .event("7c77d79c2780a074aa26891faf44d9bc1d61fb75813bb2ee9b71d787f34d6a1a"),
            .hashtag("left"),
            .hashtag("right"),
            Tag(name: .word, value: "up"),
            Tag(name: .word, value: "down")
        ]
        
        let privateTags = event.privateTags(using: Keypair.test)
        
        XCTAssertEqual(privateTags, expectedPrivateTags)
        
        try verifyEvent(event)
    }
    
    func testLongformContentEvent() throws {
        let identifier = "my-blog-post"
        let title = "My Blog Post"
        let content = "Here is my long blog post"
        let summary = "tldr: it's a blog post"
        let imageURL = try XCTUnwrap(URL(string: "https://nostr.com"))
        let hashtags = ["blog", "post"]
        
        let comps = DateComponents(calendar: Calendar(identifier: .iso8601), year: 2023, month: 11, day: 26, hour: 12)
        let publishedDate = try XCTUnwrap(comps.date)
        
        let event = try longformContentEvent(withIdentifier: identifier,
                                             title: title,
                                             markdownContent: content,
                                             summary: summary,
                                             imageURL: imageURL,
                                             hashtags: hashtags,
                                             publishedAt: publishedDate,
                                             signedBy: Keypair.test)
        
        XCTAssertEqual(event.identifier, identifier)
        XCTAssertEqual(event.title, title)
        XCTAssertEqual(event.content, content)
        XCTAssertEqual(event.summary, summary)
        XCTAssertEqual(event.imageURL, imageURL)
        XCTAssertEqual(event.hashtags, hashtags)
        XCTAssertEqual(event.publishedAt, publishedDate)
        
        try verifyEvent(event)
    }

    func testDateBasedCalendarEvent() throws {
        let identifier = "nostrica-12345"
        let title = "Nostrica"
        let description = "First Nostr unconference"

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
        XCTAssertEqual(dateBasedCalendarEvent.content, description)
        XCTAssertEqual(dateBasedCalendarEvent.startDate, startDate)
        XCTAssertEqual(dateBasedCalendarEvent.endDate, endDate)
        XCTAssertEqual(dateBasedCalendarEvent.locations, locations)
        XCTAssertEqual(dateBasedCalendarEvent.geohash, geohash)
        XCTAssertEqual(dateBasedCalendarEvent.participants, participants)
        XCTAssertEqual(dateBasedCalendarEvent.hashtags, hashtags)
        XCTAssertEqual(dateBasedCalendarEvent.references, references)

        try verifyEvent(dateBasedCalendarEvent)
    }

    func testDateBasedCalendarEventWithStartDateSameAsEndDateShouldFail() throws {
        let title = "Nostrica"
        let description = "First Nostr unconference"
        let timeOmittedDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 19))

        XCTAssertThrowsError(try dateBasedCalendarEvent(title: title, description: description, startDate: timeOmittedDate, endDate: timeOmittedDate, signedBy: Keypair.test))
    }

    func testDateBasedCalendarEventWithEndDateBeforeStartDateShouldFail() throws {
        let title = "Nostrica"
        let description = "First Nostr unconference"
        let startDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 19))
        let endDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 3, day: 18))

        XCTAssertThrowsError(try dateBasedCalendarEvent(title: title, description: description, startDate: startDate, endDate: endDate, signedBy: Keypair.test))
    }

    func testTimeBasedCalendarEvent() throws {
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

        try verifyEvent(timeBasedCalendarEvent)
    }

    func testTimeBasedCalendarEventWithStartTimestampSameAsEndTimestampShouldFail() throws {
        let title = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let timeZone = TimeZone(identifier: "America/New_York")
        let dateComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)
        let timestamp = try XCTUnwrap(dateComponents.date)

        XCTAssertThrowsError(try timeBasedCalendarEvent(title: title, description: description, startTimestamp: timestamp, endTimestamp: timestamp, signedBy: Keypair.test))
    }

    func testTimeBasedCalendarEventWithEndTimestampBeforeStartTimestampShouldFail() throws {
        let title = "Flight from New York (JFK) to San José, Costa Rica (SJO)"
        let description = "Flight to Nostrica"

        let timeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 15)
        let endComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: timeZone, year: 2023, month: 3, day: 17, hour: 8, minute: 14)

        let startTimestamp = try XCTUnwrap(startComponents.date)
        let endTimestamp = try XCTUnwrap(endComponents.date)

        XCTAssertThrowsError(try timeBasedCalendarEvent(title: title, description: description, startTimestamp: startTimestamp, endTimestamp: endTimestamp, signedBy: Keypair.test))
    }

    func testCalendar() throws {
        let timeOmittedStartDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 12, day: 31))
        let dateBasedCalendarEvent = try XCTUnwrap(dateBasedCalendarEvent(title: "New Year's Eve", startDate: timeOmittedStartDate, signedBy: Keypair.test))
        let dateBasedCalendarEventCoordinates = try XCTUnwrap(dateBasedCalendarEvent.identifierEventCoordinates())

        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.identifierEventCoordinates())

        let identifier = "family-calendar"
        let title = "Family Calendar"
        let description = "All family events."
        let calendar = try calendarNostrEvent(withIdentifier: identifier, title: title, description: description, calendarEventsCoordinates: [dateBasedCalendarEventCoordinates, timeBasedCalendarEventCoordinates], signedBy: Keypair.test)

        XCTAssertEqual(calendar.identifier, identifier)
        XCTAssertEqual(calendar.title, title)
        XCTAssertEqual(calendar.content, description)
        XCTAssertEqual(calendar.calendarEventsCoordinates, [dateBasedCalendarEventCoordinates, timeBasedCalendarEventCoordinates])

        try verifyEvent(calendar)   
    }

    func testCalendarWithNoCalendarEventCoordinates() throws {
        let identifier = "family-calendar"
        let title = "Family Calendar"
        let description = "All family events."
        let calendar = try calendarNostrEvent(withIdentifier: identifier, title: title, description: description, calendarEventsCoordinates: [], signedBy: Keypair.test)

        XCTAssertEqual(calendar.identifier, identifier)
        XCTAssertEqual(calendar.title, title)
        XCTAssertEqual(calendar.content, description)
        XCTAssertEqual(calendar.calendarEventsCoordinates, [])

        try verifyEvent(calendar)
    }

    func testCalendarWithInvalidCalendarEventCoordinatesShouldFail() throws {
        let identifier = "family-calendar"
        let title = "Family Calendar"
        let description = "All family events."
        let eventCoordinates = try XCTUnwrap(EventCoordinates(kind: EventKind.textNote, pubkey: Keypair.test.publicKey, identifier: "abc"))

        XCTAssertThrowsError(try calendarNostrEvent(withIdentifier: identifier, title: title, description: description, calendarEventsCoordinates: [eventCoordinates], signedBy: Keypair.test))
    }

    func testDateBasedCalendarEventRSVP() throws {
        let timeOmittedStartDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 12, day: 31))
        let dateBasedCalendarEvent = try XCTUnwrap(dateBasedCalendarEvent(title: "New Year's Eve", startDate: timeOmittedStartDate, signedBy: Keypair.test))
        let dateBasedCalendarEventCoordinates = try XCTUnwrap(dateBasedCalendarEvent.identifierEventCoordinates())

        let identifier = "hockey-practice-rsvp"
        let note = "Don't forget your skates!"
        let calendarEventRSVP = try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: dateBasedCalendarEventCoordinates, status: .accepted, freebusy: .busy, note: note, signedBy: Keypair.test)

        XCTAssertEqual(calendarEventRSVP.identifier, identifier)
        XCTAssertEqual(calendarEventRSVP.calendarEventCoordinates, dateBasedCalendarEventCoordinates)
        XCTAssertEqual(calendarEventRSVP.status, .accepted)
        XCTAssertEqual(calendarEventRSVP.freebusy, .busy)
        XCTAssertEqual(calendarEventRSVP.content, note)

        try verifyEvent(calendarEventRSVP)
    }

    func testTimeBasedCalendarEventRSVP() throws {
        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.identifierEventCoordinates())

        let identifier = "hockey-practice-rsvp"
        let note = "Don't forget your skates!"
        let calendarEventRSVP = try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: timeBasedCalendarEventCoordinates, status: .accepted, freebusy: .busy, note: note, signedBy: Keypair.test)

        XCTAssertEqual(calendarEventRSVP.identifier, identifier)
        XCTAssertEqual(calendarEventRSVP.calendarEventCoordinates, timeBasedCalendarEventCoordinates)
        XCTAssertEqual(calendarEventRSVP.status, .accepted)
        XCTAssertEqual(calendarEventRSVP.freebusy, .busy)
        XCTAssertEqual(calendarEventRSVP.content, note)

        try verifyEvent(calendarEventRSVP)
    }

    func testCalendarEventRSVPWithInvalidCalendarEventCoordinatesShouldFail() throws {
        let identifier = "hockey-practice-rsvp"
        let note = "Don't forget your skates!"
        let eventCoordinates = try XCTUnwrap(EventCoordinates(kind: EventKind.textNote, pubkey: Keypair.test.publicKey, identifier: "abc"))

        XCTAssertThrowsError(try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: eventCoordinates, status: .accepted, freebusy: .busy, note: note, signedBy: Keypair.test))
    }

    func testCalendarEventRSVPWithDeclineAndNoFreebusy() throws {
        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.identifierEventCoordinates())

        let identifier = "hockey-practice-rsvp"
        let calendarEventRSVP = try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: timeBasedCalendarEventCoordinates, status: .declined, signedBy: Keypair.test)

        XCTAssertEqual(calendarEventRSVP.identifier, identifier)
        XCTAssertEqual(calendarEventRSVP.calendarEventCoordinates, timeBasedCalendarEventCoordinates)
        XCTAssertEqual(calendarEventRSVP.status, .declined)
        XCTAssertNil(calendarEventRSVP.freebusy)

        try verifyEvent(calendarEventRSVP)
    }

    func testCalendarEventRSVPWithDeclineAndFreebusyShouldFail() throws {
        let startTimeZone = TimeZone(identifier: "America/New_York")
        let startComponents = DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: startTimeZone, year: 2023, month: 12, day: 20, hour: 8, minute: 0)
        let startDate = try XCTUnwrap(startComponents.date)
        let timeBasedCalendarEvent = try timeBasedCalendarEvent(title: "Hockey Practice", startTimestamp: startDate, signedBy: Keypair.test)
        let timeBasedCalendarEventCoordinates = try XCTUnwrap(timeBasedCalendarEvent.identifierEventCoordinates())

        let identifier = "hockey-practice-rsvp"
        XCTAssertThrowsError(try calendarEventRSVP(withIdentifier: identifier, calendarEventCoordinates: timeBasedCalendarEventCoordinates, status: .declined, freebusy: .busy, signedBy: Keypair.test))
    }
}
