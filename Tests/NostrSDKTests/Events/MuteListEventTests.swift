//
//  MuteListEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class MuteListEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateMuteListEvent() throws {
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

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .muteList, pubkey: Keypair.test.publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(event)
    }

    func testDecodeMuteListEvent() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")

        XCTAssertEqual(event.id, "acfc1402d926b88a26dffc94162e399f2b35d7c7503a1fde2f2cc6d11d33ad88")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .muteList)

        XCTAssertTrue(event.tags.contains(.pubkey("07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f")))
        XCTAssertTrue(event.tags.contains(.hashtag("testing")))
        XCTAssertTrue(event.tags.contains(.hashtag("test2")))

        let privateTags = event.privateTags(using: .test)
        XCTAssertTrue(privateTags.contains(.pubkey("6e468422dfb74a5738702a8823b9b28168abab8655faacb6853cd0ee15deee93")))
        XCTAssertTrue(privateTags.contains(.hashtag("sportsball")))
        XCTAssertTrue(privateTags.contains(.hashtag("footstr")))

        XCTAssertEqual(event.privateHashtags(using: .test), ["sportsball", "footstr"])
    }

}
