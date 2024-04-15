//
//  BookmarksListEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class BookmarksListEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateBookmarkList() throws {
        let publicCoordinates = try XCTUnwrap(try EventCoordinates(kind: .longformContent, pubkey: Keypair.test.publicKey, identifier: "the-public-one"))
        let publicTags: [Tag] = [
            .event("test-id", otherParameters: ["wss://relay.com"]),
            .hashtag("nostra"),
            .link(URL(string: "https://www.nostr.com")!),
            publicCoordinates.tag
        ]

        let privateCoordinates = try XCTUnwrap(try EventCoordinates(kind: .longformContent, pubkey: Keypair.test.publicKey, identifier: "the-private-one"))
        let privateTags: [Tag] = [
            .event("test-id-private", otherParameters: ["wss://relay.com"]),
            .hashtag("noster"),
            .link(URL(string: "https://www.private.net")!),
            privateCoordinates.tag
        ]

        let bookmarks = try bookmarksList(withPublicTags: publicTags,
                                          privateTags: privateTags,
                                          signedBy: .test)

        XCTAssertEqual(bookmarks.noteIds, ["test-id"])
        XCTAssertEqual(bookmarks.hashtags, ["nostra"])
        XCTAssertEqual(bookmarks.links, [URL(string: "https://www.nostr.com")!])
        XCTAssertEqual(bookmarks.articlesCoordinates, [publicCoordinates])

        XCTAssertEqual(bookmarks.privateNoteIds(using: .test), ["test-id-private"])
        XCTAssertEqual(bookmarks.privateHashtags(using: .test), ["noster"])
        XCTAssertEqual(bookmarks.privateLinks(using: .test), [URL(string: "https://www.private.net")!])
        XCTAssertEqual(bookmarks.privateArticlesCoordinates(using: .test), [privateCoordinates])

        XCTAssertEqual(bookmarks.noteTags, [Tag.event("test-id", otherParameters: ["wss://relay.com"])])
        XCTAssertEqual(bookmarks.privateNoteTags(using: .test), [Tag.event("test-id-private", otherParameters: ["wss://relay.com"])])

        try verifyEvent(bookmarks)
    }

    func testCreateBookmarkListFailsWithUnexpectedTag() throws {
        XCTAssertThrowsError(try bookmarksList(withPublicTags: [Tag(name: .title, value: "hello world")], signedBy: .test))
    }

    func testDecodeBookmarksListEvent() throws {
        let event: BookmarksListEvent = try decodeFixture(filename: "bookmarks")

        XCTAssertEqual(event.id, "60cf106df8f7e4437db3119f3795607961d9b764a622eca67d97db60ee1313d8")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .bookmarksList)

        XCTAssertTrue(event.noteIds.contains("be8567dc210986fe5dc0ad04e02a8850b3b86e1d30c0ab674d102f0eefa68921"))
        XCTAssertTrue(event.hashtags.contains("up"))
        XCTAssertTrue(event.links.contains(URL(string: "https://nostr.com/")!))
        let coordinates = try XCTUnwrap(EventCoordinates(kind: .longformContent,
                                                         pubkey: PublicKey(hex: "599f67f7df7694c603a6d0636e15ebc610db77dcfd47d6e5d05386d821fb3ea9")!,
                                                         identifier: "1700730909108",
                                                         relayURL: URL(string: "wss://relay.nostr.band")))
        XCTAssertTrue(event.articlesCoordinates.contains(coordinates))

        XCTAssertTrue(event.privateNoteIds(using: .test).contains("65eff7eb588f169789026d2915c1fe6aaa3be0b855cebeb32b727f68c54c5a64"))
        XCTAssertTrue(event.privateHashtags(using: .test).contains("down"))
        XCTAssertTrue(event.privateLinks(using: .test).contains(URL(string: "https://www.apple.com/")!))
        XCTAssertTrue(event.privateArticlesCoordinates(using: .test).contains(coordinates))
    }
    
}
