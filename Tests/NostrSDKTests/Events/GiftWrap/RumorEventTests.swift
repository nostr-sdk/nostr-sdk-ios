//
//  RumorEventTests.swift
//  
//
//  Created by Terry Yiu on 5/17/24.
//

@testable import NostrSDK
import XCTest

final class RumorEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateRumor() throws {
        let signedEvent = TextNoteEvent.Builder()
            .content("Are you going to the party tonight?")
            .build(pubkey: Keypair.test.publicKey)
        let rumor = signedEvent.rumor

        XCTAssertEqual(rumor.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(rumor.kind, .textNote)
        XCTAssertEqual(rumor.tags, [])
        XCTAssertNil(rumor.signature)
        XCTAssertTrue(rumor.isRumor)
        XCTAssertEqual(rumor.content, "Are you going to the party tonight?")

        XCTAssertThrowsError(try verifyEvent(rumor))
    }

    func testCreateRumorFromSignedEvent() throws {
        let signedEvent = try TextNoteEvent.Builder()
            .content("Are you going to the party tonight?")
            .build(signedBy: .test)
        let rumor = signedEvent.rumor

        XCTAssertEqual(rumor.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(rumor.kind, .textNote)
        XCTAssertEqual(rumor.tags, [])
        XCTAssertNil(rumor.signature)
        XCTAssertTrue(rumor.isRumor)
        XCTAssertEqual(rumor.content, "Are you going to the party tonight?")

        XCTAssertThrowsError(try verifyEvent(rumor))
    }

    func testDecodeRumor() throws {
        let rumor: NostrEvent = try decodeFixture(filename: "rumor")

        XCTAssertEqual(rumor.id, "9dd003c6d3b73b74a85a9ab099469ce251653a7af76f523671ab828acd2a0ef9")
        XCTAssertEqual(rumor.pubkey, "611df01bfcf85c26ae65453b772d8f1dfd25c264621c0277e1fc1518686faef9")
        XCTAssertEqual(rumor.createdAt, 1691518405)
        XCTAssertEqual(rumor.kind, .textNote)
        XCTAssertEqual(rumor.tags, [])
        XCTAssertNil(rumor.signature)
        XCTAssertTrue(rumor.isRumor)
        XCTAssertEqual(rumor.content, "Are you going to the party tonight?")
    }

}
