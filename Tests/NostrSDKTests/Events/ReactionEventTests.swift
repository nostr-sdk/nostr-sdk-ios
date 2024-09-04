//
//  ReactionEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class ReactionEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateReactionEvent() throws {
        let reactedEvent = try TextNoteEvent.Builder()
            .content("Hello world!")
            .build(signedBy: Keypair.test)
        let event = try reaction(withContent: "🤙",
                                 reactedEvent: reactedEvent,
                                 signedBy: .test)

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
        let reactedEvent = try TextNoteEvent.Builder()
            .build(signedBy: .test)

        let imageURLString = "https://nostrsdk.com/ostrich.png"
        let imageURL = try XCTUnwrap(URL(string: imageURLString))
        let customEmoji = try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: imageURL))
        let event = try reaction(withCustomEmoji: customEmoji,
                                 reactedEvent: reactedEvent,
                                 signedBy: .test)

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

    func testDecodeReaction() throws {
        let event: ReactionEvent = try decodeFixture(filename: "reaction")

        XCTAssertEqual(event.id, "8a3217770794fabe89adac500dcd5d38966d3ba3cb83fabc97b58135980f76cd")
        XCTAssertEqual(event.pubkey, "2779f3d9f42c7dee17f0e6bcdcf89a8f9d592d19e3b1bbd27ef1cffd1a7f98d1")
        XCTAssertEqual(event.createdAt, 1689029084)
        XCTAssertEqual(event.kind, .reaction)

        let expectedTags: [Tag] = [
            .event("62dcc905c282dd712bbe6b47d2e40feb333f8a0c39899617f4ca37337199ede0"),
            .pubkey("e1ff3bfdd4e40315959b08b4fcc8245eaa514637e1d4ec2ae166b743341be1af")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.reactedEventId, "62dcc905c282dd712bbe6b47d2e40feb333f8a0c39899617f4ca37337199ede0")
        XCTAssertEqual(event.reactedEventPubkey, "e1ff3bfdd4e40315959b08b4fcc8245eaa514637e1d4ec2ae166b743341be1af")
        XCTAssertEqual(event.content, "🤙")
        XCTAssertEqual(event.signature, "c0dea5d4612d834e13e0dcfeff71a345f761d868bf27fd5e3fe521b76872d5da3db05375f8739a4bad86189d63720187c08170827990b113b477437f17e4a906")
    }

    func testDecodeCustomEmojiReaction() throws {
        let event: ReactionEvent = try decodeFixture(filename: "custom_emoji_reaction")

        XCTAssertEqual(event.id, "342439c681a0db193992d144c38fce09deaa49e5d441fea6561175982f518f7d")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1699768152)
        XCTAssertEqual(event.kind, .reaction)

        let expectedTags: [Tag] = [
            .event("dc0e8b27b37ec7854ec0d5b24c39901a8cf933be3b420ca3cee6242279f54a48"),
            .pubkey("9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"),
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"])
        ]
        let imageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        XCTAssertEqual(event.customEmojis, [CustomEmoji(shortcode: "ostrich", imageURL: imageURL)])
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.reactedEventId, "dc0e8b27b37ec7854ec0d5b24c39901a8cf933be3b420ca3cee6242279f54a48")
        XCTAssertEqual(event.reactedEventPubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.content, ":ostrich:")
        XCTAssertEqual(event.signature, "eb20aaff71b309b386ed12a92208fd6a8322b66585331d039d63219c0724752a2ffee211ed99d1dd370f601282f0d3c49c36a28ac4252ee4d0f3f1ce0de06abb")
    }

}
