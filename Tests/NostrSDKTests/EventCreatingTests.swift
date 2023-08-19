//
//  EventCreatingTests.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation
@testable import NostrSDK
import XCTest

final class EventCreatingTests: XCTestCase, EventCreating, EventVerifying {
    
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
}
