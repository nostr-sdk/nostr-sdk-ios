//
//  RepostEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class RepostEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateRepostTextNoteEvent() throws {
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

    func testCreateRepostNonTextNoteEvent() throws {
        let eventToRepost: LongformContentEvent = try decodeFixture(filename: "longform")

        let repostEvent = try repost(event: eventToRepost, signedBy: Keypair.test)
        XCTAssertFalse(repostEvent is TextNoteRepostEvent)
        XCTAssertEqual(repostEvent.kind, .genericRepost)

        XCTAssertTrue(repostEvent.tags.contains(.pubkey("7489688c05bb72112dd82d54fdbf26bb5f03e1de48e97861d8fce294a2f16946")))
        XCTAssertTrue(repostEvent.tags.contains(.event("8f4b2477881ec73c824410610709163f6a4e8fda067de8c4bbd0a9e337901eac")))
        XCTAssertTrue(repostEvent.tags.contains(.kind(.longformContent)))

        let repostedEvent = try XCTUnwrap(repostEvent.repostedEvent)
        XCTAssertEqual(repostedEvent.id, "8f4b2477881ec73c824410610709163f6a4e8fda067de8c4bbd0a9e337901eac")
        XCTAssertEqual(repostedEvent.pubkey, "7489688c05bb72112dd82d54fdbf26bb5f03e1de48e97861d8fce294a2f16946")
        XCTAssertEqual(repostedEvent.createdAt, 1700532108)

        try verifyEvent(repostEvent)
    }

    func testDecodeRepost() throws {

        let event: TextNoteRepostEvent = try decodeFixture(filename: "repost")

        XCTAssertEqual(event.id, "9353c66d99d600f51b9b1f309b804d2156facd227d643eb513eb8c508498da21")
        XCTAssertEqual(event.pubkey, "91c9a5e1a9744114c6fe2d61ae4de82629eaaa0fb52f48288093c7e7e036f832")
        XCTAssertEqual(event.createdAt, 1684817569)
        XCTAssertEqual(event.kind, .repost)

        let expectedTags: [Tag] = [
            .event("6663efd8ffb35325af90a84cb223dc388e9d355abf7319fe5c4c5ca7f37e9a34"),
            .pubkey("33eecd2e2fae31f36c0bdb843d43611426ee5c023889f0401c1b8f5008e59689")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertTrue(event.content.hasPrefix("{\"pubkey\":\"33eecd2e2fae31f36c0bdb843d43611426ee5c023889f0401c1b8f5008e59689\""))
        XCTAssertEqual(event.signature, "8c81d6c5b44f134bdded8f6d20c9d299fcbe3bc9687df14d7516e4781b60a00fa7bb71eb73e29c3ca3bc6da2198710c82f64859f79ea33434cffa4d80c29b1c2")

        XCTAssertEqual(event.repostedEventId, "6663efd8ffb35325af90a84cb223dc388e9d355abf7319fe5c4c5ca7f37e9a34")

        let repostedNote = try XCTUnwrap(event.repostedNote)
        XCTAssertEqual(repostedNote.id, "6663efd8ffb35325af90a84cb223dc388e9d355abf7319fe5c4c5ca7f37e9a34")
        XCTAssertEqual(repostedNote.pubkey, "33eecd2e2fae31f36c0bdb843d43611426ee5c023889f0401c1b8f5008e59689")
        XCTAssertEqual(repostedNote.createdAt, 1684482315)
    }

    func testDecodeGenericRepost() throws {

        let event: GenericRepostEvent = try decodeFixture(filename: "generic_repost")

        XCTAssertEqual(event.repostedEventPubkey, "7489688c05bb72112dd82d54fdbf26bb5f03e1de48e97861d8fce294a2f16946")
        XCTAssertEqual(event.repostedEventId, "8f4b2477881ec73c824410610709163f6a4e8fda067de8c4bbd0a9e337901eac")
        XCTAssertEqual(event.repostedEventRelayURL?.absoluteString, "wss://reposted.relay")

        let repostedEvent = try XCTUnwrap(event.repostedEvent)

        XCTAssertEqual(repostedEvent.id, "8f4b2477881ec73c824410610709163f6a4e8fda067de8c4bbd0a9e337901eac")
        XCTAssertEqual(repostedEvent.kind, .longformContent)
    }

}
