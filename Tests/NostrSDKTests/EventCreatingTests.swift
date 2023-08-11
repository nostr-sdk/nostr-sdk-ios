//
//  EventCreatingTests.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation
import NostrSDK
import XCTest

final class EventCreatingTests: XCTestCase, EventCreating, EventVerifying {

    func testDirectMessageEvent() throws {
        let content = "Secret message."
        let recipientPubKey = Keypair.test.publicKey
        let recipientTag = Tag(name: .pubkey, value: recipientPubKey.hex)

        let event = try directMessage(withContent: content, recipient: recipientPubKey, signedBy: Keypair.test)

        // Content should contain "?iv=" if encrypted
        XCTAssert(event.content.contains("?iv="))

        // Recipient should be tagged
        let tag = try XCTUnwrap(event.tags.first)
        XCTAssertEqual(tag, recipientTag)
    }
    
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
}
