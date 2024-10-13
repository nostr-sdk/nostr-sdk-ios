//
//  DirectMessageEventTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/19/24.
//

@testable import NostrSDK
import XCTest

final class DirectMessageEventTests: XCTestCase, EventCreating, RelayURLValidating {

    func testCreateDirectMessage() throws {
        let keypair1 = try XCTUnwrap(Keypair())
        let keypair2 = try XCTUnwrap(Keypair())
        let keypair3 = try XCTUnwrap(Keypair())

        let relayURLString1 = "wss://relay.primal.net"
        let relayURLString2 = "wss://relay.damus.io"

        let subject = "This is the chat room topic."
        let content = "GM, fiatjaf!"

        let directMessageEvent = DirectMessageEvent.Builder()
            .appendTags(
                .pubkey(keypair2.publicKey.hex, otherParameters: [relayURLString1]),
                .pubkey(keypair3.publicKey.hex, otherParameters: [relayURLString2])
            )
            .subject(subject)
            .content(content)
            .build(pubkey: keypair1.publicKey)

        XCTAssertEqual(directMessageEvent.kind, .directMessage)
        XCTAssertEqual(directMessageEvent.pubkey, keypair1.publicKey.hex)
        XCTAssertEqual(directMessageEvent.referencedEventIds, [])
        XCTAssertEqual(Set(directMessageEvent.referencedPubkeys), Set([keypair2.publicKey.hex, keypair3.publicKey.hex]))
        XCTAssertEqual(directMessageEvent.content, content)
        XCTAssertEqual(directMessageEvent.subject, subject)
        XCTAssertTrue(directMessageEvent.isRumor)

        let giftWrapEvent1 = try giftWrap(withDirectMessageEvent: directMessageEvent, toRecipient: keypair1.publicKey, signedBy: keypair1)
        let giftWrapEvent2 = try giftWrap(withDirectMessageEvent: directMessageEvent, toRecipient: keypair2.publicKey, signedBy: keypair1)
        let giftWrapEvent3 = try giftWrap(withDirectMessageEvent: directMessageEvent, toRecipient: keypair3.publicKey, signedBy: keypair1)

        let unsealedRumor1 = try XCTUnwrap(giftWrapEvent1.unsealedRumor(using: keypair1.privateKey))
        let unsealedRumor2 = try XCTUnwrap(giftWrapEvent2.unsealedRumor(using: keypair2.privateKey))
        let unsealedRumor3 = try XCTUnwrap(giftWrapEvent3.unsealedRumor(using: keypair3.privateKey))

        XCTAssertEqual(directMessageEvent, unsealedRumor1)
        XCTAssertEqual(directMessageEvent, unsealedRumor2)
        XCTAssertEqual(directMessageEvent, unsealedRumor3)
    }

    func testCreateDirectMessageWithRecipientAlias() throws {
        let keypair1 = try XCTUnwrap(Keypair())
        let keypair2 = try XCTUnwrap(Keypair())
        let keypair2Alias = try XCTUnwrap(Keypair())
        let keypair3 = try XCTUnwrap(Keypair())

        let relayURLString1 = "wss://relay.primal.net"
        let relayURLString2 = "wss://relay.damus.io"

        let subject = "This is the chat room topic."
        let content = "GM, fiatjaf!"

        let directMessageEvent = DirectMessageEvent.Builder()
            .appendTags(
                .pubkey(keypair2.publicKey.hex, otherParameters: [relayURLString1]),
                .pubkey(keypair3.publicKey.hex, otherParameters: [relayURLString2])
            )
            .subject(subject)
            .content(content)
            .build(pubkey: keypair1.publicKey)

        XCTAssertEqual(directMessageEvent.kind, .directMessage)
        XCTAssertEqual(directMessageEvent.pubkey, keypair1.publicKey.hex)
        XCTAssertEqual(directMessageEvent.referencedEventIds, [])
        XCTAssertEqual(Set(directMessageEvent.referencedPubkeys), Set([keypair2.publicKey.hex, keypair3.publicKey.hex]))
        XCTAssertEqual(directMessageEvent.content, content)
        XCTAssertEqual(directMessageEvent.subject, subject)
        XCTAssertTrue(directMessageEvent.isRumor)

        let giftWrapEvent1 = try giftWrap(withDirectMessageEvent: directMessageEvent, toRecipient: keypair1.publicKey, signedBy: keypair1)
        let giftWrapEvent2 = try giftWrap(withDirectMessageEvent: directMessageEvent, toRecipient: keypair2.publicKey, recipientAlias: keypair2Alias.publicKey, signedBy: keypair1)
        let giftWrapEvent3 = try giftWrap(withDirectMessageEvent: directMessageEvent, toRecipient: keypair3.publicKey, signedBy: keypair1)

        let unsealedRumor1 = try XCTUnwrap(giftWrapEvent1.unsealedRumor(using: keypair1.privateKey))
        let unsealedRumor2 = try XCTUnwrap(giftWrapEvent2.unsealedRumor(using: keypair2.privateKey))
        let unsealedRumor3 = try XCTUnwrap(giftWrapEvent3.unsealedRumor(using: keypair3.privateKey))

        XCTAssertEqual(directMessageEvent, unsealedRumor1)
        XCTAssertEqual(directMessageEvent, unsealedRumor2)
        XCTAssertEqual(directMessageEvent, unsealedRumor3)
    }

    func testCreateDirectMessageTopLevelReply() throws {
        let keypair1 = try XCTUnwrap(Keypair())
        let keypair2 = try XCTUnwrap(Keypair())
        let keypair3 = try XCTUnwrap(Keypair())

        let relayURLString1 = "wss://relay.primal.net"
        let relayURLString2 = "wss://relay.damus.io"
        let relayURL1 = URL(string: relayURLString1)

        let subject = "Nostr Friends & Family"
        let content = "I am!"

        let rootDirectMessageEvent = DirectMessageEvent.Builder()
            .appendTags(
                .pubkey(keypair2.publicKey.hex, otherParameters: [relayURLString1]),
                .pubkey(keypair3.publicKey.hex, otherParameters: [relayURLString2])
            )
            .subject("Nostr Friends")
            .content("Is anyone going to the next Nostr conference?")
            .build(pubkey: keypair1.publicKey)

        let replyDirectMessageEvent = try DirectMessageEvent.Builder()
            .repliedEvent(rootDirectMessageEvent, relayURL: relayURL1)
            .subject(subject)
            .content(content)
            .build(pubkey: keypair2.publicKey)

        XCTAssertEqual(replyDirectMessageEvent.kind, .directMessage)
        XCTAssertEqual(replyDirectMessageEvent.pubkey, keypair2.publicKey.hex)
        XCTAssertEqual(replyDirectMessageEvent.referencedEventIds, [rootDirectMessageEvent.id])
        XCTAssertEqual(Set(replyDirectMessageEvent.referencedPubkeys), Set([keypair1.publicKey.hex, keypair2.publicKey.hex, keypair3.publicKey.hex]))
        XCTAssertEqual(replyDirectMessageEvent.content, content)
        XCTAssertEqual(replyDirectMessageEvent.subject, subject)
        XCTAssertTrue(replyDirectMessageEvent.isRumor)

        let rootEventTag = try XCTUnwrap(replyDirectMessageEvent.rootEventTag)
        XCTAssertEqual(rootEventTag.eventId, rootDirectMessageEvent.id)
        XCTAssertEqual(rootEventTag.relayURL, relayURL1)
        XCTAssertEqual(rootEventTag.marker, .root)
        XCTAssertEqual(rootEventTag.pubkey, keypair1.publicKey.hex)

        let replyEventTag = try XCTUnwrap(replyDirectMessageEvent.replyEventTag)
        XCTAssertEqual(replyEventTag.eventId, rootDirectMessageEvent.id)
        XCTAssertEqual(replyEventTag.relayURL, relayURL1)
        XCTAssertEqual(replyEventTag.marker, .root)
        XCTAssertEqual(replyEventTag.pubkey, keypair1.publicKey.hex)

        XCTAssertEqual(replyDirectMessageEvent.mentionedEventTags, [])

        let giftWrapEvent1 = try giftWrap(withDirectMessageEvent: replyDirectMessageEvent, toRecipient: keypair1.publicKey, signedBy: keypair2)
        let giftWrapEvent2 = try giftWrap(withDirectMessageEvent: replyDirectMessageEvent, toRecipient: keypair2.publicKey, signedBy: keypair2)
        let giftWrapEvent3 = try giftWrap(withDirectMessageEvent: replyDirectMessageEvent, toRecipient: keypair3.publicKey, signedBy: keypair2)

        let unsealedRumor1 = try XCTUnwrap(giftWrapEvent1.unsealedRumor(using: keypair1.privateKey))
        let unsealedRumor2 = try XCTUnwrap(giftWrapEvent2.unsealedRumor(using: keypair2.privateKey))
        let unsealedRumor3 = try XCTUnwrap(giftWrapEvent3.unsealedRumor(using: keypair3.privateKey))

        XCTAssertEqual(replyDirectMessageEvent, unsealedRumor1)
        XCTAssertEqual(replyDirectMessageEvent, unsealedRumor2)
        XCTAssertEqual(replyDirectMessageEvent, unsealedRumor3)
    }

    func testCreateDirectMessageThreadedReply() throws {
        let keypair1 = try XCTUnwrap(Keypair())
        let keypair2 = try XCTUnwrap(Keypair())
        let keypair3 = try XCTUnwrap(Keypair())

        let relayURLString1 = "wss://relay.primal.net"
        let relayURLString2 = "wss://relay.damus.io"
        let relayURL1 = URL(string: relayURLString1)
        let relayURL2 = URL(string: relayURLString2)

        let content = "Where is the conference going to be held?"

        let rootDirectMessageEvent = DirectMessageEvent.Builder()
            .appendTags(
                .pubkey(keypair2.publicKey.hex, otherParameters: [relayURLString1]),
                .pubkey(keypair3.publicKey.hex, otherParameters: [relayURLString2])
            )
            .subject("Nostr Friends")
            .content("Is anyone going to the next Nostr conference?")
            .build(pubkey: keypair1.publicKey)

        let topLevelReplyDirectMessageEvent = try DirectMessageEvent.Builder()
            .repliedEvent(rootDirectMessageEvent, relayURL: relayURL1)
            .subject("Nostr Friends & Family")
            .content("I am!")
            .build(pubkey: keypair2.publicKey)

        let threadedReplyDirectMessageEvent = try DirectMessageEvent.Builder()
            .repliedEvent(topLevelReplyDirectMessageEvent, relayURL: relayURL2)
            .content(content)
            .build(pubkey: keypair3.publicKey)

        XCTAssertEqual(threadedReplyDirectMessageEvent.kind, .directMessage)
        XCTAssertEqual(threadedReplyDirectMessageEvent.pubkey, keypair3.publicKey.hex)
        XCTAssertEqual(threadedReplyDirectMessageEvent.referencedEventIds, [rootDirectMessageEvent.id, topLevelReplyDirectMessageEvent.id])
        XCTAssertEqual(Set(threadedReplyDirectMessageEvent.referencedPubkeys), Set([keypair1.publicKey.hex, keypair2.publicKey.hex, keypair3.publicKey.hex]))
        XCTAssertEqual(threadedReplyDirectMessageEvent.content, content)
        XCTAssertNil(threadedReplyDirectMessageEvent.subject)
        XCTAssertTrue(threadedReplyDirectMessageEvent.isRumor)

        let rootEventTag = try XCTUnwrap(threadedReplyDirectMessageEvent.rootEventTag)
        XCTAssertEqual(rootEventTag.eventId, rootDirectMessageEvent.id)
        XCTAssertEqual(rootEventTag.relayURL, relayURL1)
        XCTAssertEqual(rootEventTag.marker, .root)
        XCTAssertEqual(rootEventTag.pubkey, keypair1.publicKey.hex)

        let replyEventTag = try XCTUnwrap(threadedReplyDirectMessageEvent.replyEventTag)
        XCTAssertEqual(replyEventTag.eventId, topLevelReplyDirectMessageEvent.id)
        XCTAssertEqual(replyEventTag.relayURL, relayURL2)
        XCTAssertEqual(replyEventTag.marker, .reply)
        XCTAssertEqual(replyEventTag.pubkey, keypair2.publicKey.hex)

        XCTAssertEqual(threadedReplyDirectMessageEvent.mentionedEventTags, [])

        let giftWrapEvent1 = try giftWrap(withDirectMessageEvent: threadedReplyDirectMessageEvent, toRecipient: keypair1.publicKey, signedBy: keypair3)
        let giftWrapEvent2 = try giftWrap(withDirectMessageEvent: threadedReplyDirectMessageEvent, toRecipient: keypair2.publicKey, signedBy: keypair3)
        let giftWrapEvent3 = try giftWrap(withDirectMessageEvent: threadedReplyDirectMessageEvent, toRecipient: keypair3.publicKey, signedBy: keypair3)

        let unsealedRumor1 = try XCTUnwrap(giftWrapEvent1.unsealedRumor(using: keypair1.privateKey))
        let unsealedRumor2 = try XCTUnwrap(giftWrapEvent2.unsealedRumor(using: keypair2.privateKey))
        let unsealedRumor3 = try XCTUnwrap(giftWrapEvent3.unsealedRumor(using: keypair3.privateKey))

        XCTAssertEqual(threadedReplyDirectMessageEvent, unsealedRumor1)
        XCTAssertEqual(threadedReplyDirectMessageEvent, unsealedRumor2)
        XCTAssertEqual(threadedReplyDirectMessageEvent, unsealedRumor3)
    }

}
