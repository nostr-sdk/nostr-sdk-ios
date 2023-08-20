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
        let meta = UserMetadata(name: "Nostr SDK Test",
                                about: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms.",
                                website: URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios")!,
                                nostrAddress: "test@nostr.com",
                                pictureURL: URL(string: "picture@nostr.com"),
                                bannerPictureURL: URL(string: "banner@nostr.com")!)
        
        let event = try setMetadataEvent(withUserMetadata: meta, signedBy: Keypair.test)
        
        XCTAssertEqual(event.userMetadata?.name, "Nostr SDK Test")
        XCTAssertEqual(event.userMetadata?.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms.")
        XCTAssertEqual(event.userMetadata?.website, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.userMetadata?.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.userMetadata?.pictureURL, URL(string: "picture@nostr.com"))
        XCTAssertEqual(event.userMetadata?.bannerPictureURL, URL(string: "banner@nostr.com"))
        
        try verifyEvent(event)
    }
    
    func testCreateSignedTextNote() throws {
        let note = try textNote(withContent: "Hello world!",
                                signedBy: Keypair.test)
        
        XCTAssertEqual(note.kind, .textNote)
        XCTAssertEqual(note.content, "Hello world!")
        XCTAssertEqual(note.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(note.tags, [])
        
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
}
