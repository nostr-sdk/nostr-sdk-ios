//
//  LongformContentEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class LongformContentEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateLongformContentEvent() throws {
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

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .longformContent, pubkey: Keypair.test.publicKey, identifier: identifier))
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        try verifyEvent(event)
    }

    func testDecodeLongformContentEvent() throws {
        let event: LongformContentEvent = try decodeFixture(filename: "longform")

        XCTAssertEqual(event.kind, .longformContent)
        XCTAssertEqual(event.id, "8f4b2477881ec73c824410610709163f6a4e8fda067de8c4bbd0a9e337901eac")
        XCTAssertEqual(event.identifier, "F8SII-G5LDumDZgxGCVQS")
        XCTAssertEqual(event.title, "Embracing Decentralization: Is Nostr the Answer to Social Network Concerns?")
        XCTAssertEqual(event.summary, "")
        XCTAssertEqual(event.imageURL, URL(string: "https://yakihonne.s3.ap-east-1.amazonaws.com/7489688c05bb72112dd82d54fdbf26bb5f03e1de48e97861d8fce294a2f16946/files/1700532108836-YAKIHONNES3.jpg"))
        XCTAssertEqual(event.hashtags, ["Yakihonne Zap round 11"])
        XCTAssertTrue(event.content.hasPrefix("![image](https://yakihonne.s3.ap-east-1.amazonaws.com/7489688c05b"))
        XCTAssertTrue(event.content.hasSuffix("attracted Bitcoiners to the protocol."))

        let publishedAt = try XCTUnwrap(event.publishedAt?.timeIntervalSince1970)
        XCTAssertEqual(Int64(publishedAt), 1700532108)
    }

}
