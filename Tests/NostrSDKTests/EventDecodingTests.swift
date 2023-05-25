//
//  EventDecodingTests.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

@testable import NostrSDK
import XCTest

final class EventDecodingTests: XCTestCase {

    let fixtureLoader = FixtureLoader()

    func testDecodeSetMetadata() throws {
        guard let data = fixtureLoader.loadFixture("set_metadata") else {
            XCTFail("failed to load fixture")
            return
        }

        let event = try JSONDecoder().decode(NostrEvent.self, from: data)

        XCTAssertEqual(event.id, "d214c914b0ab49ec919fa5f60fabf746f421e432d96f941bd2573e4d22e36b51")
        XCTAssertEqual(event.pubkey, "00000000827ffaa94bfea288c3dfce4422c794fbb96625b6b31e9049f729d700")
        XCTAssertEqual(event.createdAt, 1684370291)
        XCTAssertEqual(event.kind, .setMetadata)
        XCTAssertEqual(event.tags, [])
        XCTAssertTrue(event.content.hasPrefix("{\"banner\":\"https://nostr.build/i/nostr.build"))
        XCTAssertEqual(event.signature, "7bb7f031fbf41f49eeb44fdfb061bc8d143197d33fae8d29b017709adf2b17c76e78ccb2ee128ee93d0661cad4c626a747d48a178745c94944a693ff31ea7619")
    }

    func testDecodeTextNote() throws {
        guard let data = fixtureLoader.loadFixture("text_note") else {
            XCTFail("failed to load fixture")
            return
        }

        let event = try JSONDecoder().decode(NostrEvent.self, from: data)

        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(event.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(event.createdAt, 1682080184)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags = [
            EventTag(identifier: .event, contentIdentifier: "93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"),
            EventTag(identifier: .pubkey, contentIdentifier: "f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ")
        XCTAssertEqual(event.signature, "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")
    }

    func testDecodeRepost() throws {
        guard let data = fixtureLoader.loadFixture("repost") else {
            XCTFail("failed to load fixture")
            return
        }

        let event = try JSONDecoder().decode(NostrEvent.self, from: data)

        XCTAssertEqual(event.id, "9353c66d99d600f51b9b1f309b804d2156facd227d643eb513eb8c508498da21")
        XCTAssertEqual(event.pubkey, "91c9a5e1a9744114c6fe2d61ae4de82629eaaa0fb52f48288093c7e7e036f832")
        XCTAssertEqual(event.createdAt, 1684817569)
        XCTAssertEqual(event.kind, .repost)

        let expectedTags = [
            EventTag(identifier: .event, contentIdentifier: "6663efd8ffb35325af90a84cb223dc388e9d355abf7319fe5c4c5ca7f37e9a34"),
            EventTag(identifier: .pubkey, contentIdentifier: "33eecd2e2fae31f36c0bdb843d43611426ee5c023889f0401c1b8f5008e59689")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertTrue(event.content.hasPrefix("{\"pubkey\":\"33eecd2e2fae31f36c0bdb843d43611426ee5c023889f0401c1b8f5008e59689\""))
        XCTAssertEqual(event.signature, "8c81d6c5b44f134bdded8f6d20c9d299fcbe3bc9687df14d7516e4781b60a00fa7bb71eb73e29c3ca3bc6da2198710c82f64859f79ea33434cffa4d80c29b1c2")
    }
}
