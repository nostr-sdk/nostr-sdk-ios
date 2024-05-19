//
//  AuthenticationEventTests.swift
//
//
//  Created by Terry Yiu on 5/2/24.
//

@testable import NostrSDK
import XCTest

final class AuthenticationEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateAuthenticationEvent() throws {
        let relayURL = try XCTUnwrap(URL(string: "wss://relay.example.com/"))
        let event = try authenticate(relayURL: relayURL, challenge: "some-challenge-string", signedBy: Keypair.test)

        XCTAssertEqual(event.kind, .authentication)
        XCTAssertEqual(event.relayURL, relayURL)
        XCTAssertEqual(event.challenge, "some-challenge-string")

        try verifyEvent(event)
    }

    func testDecodeAuthenticationEvent() throws {
        let event: AuthenticationEvent = try decodeFixture(filename: "authentication_event")

        XCTAssertEqual(event.id, "adb599bc2f6b4cf97d927de2cb36829326c86013e0a6e8f51159f80938a5c246")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1714625219)
        XCTAssertEqual(event.kind, .authentication)

        let expectedTags: [Tag] = [
            Tag(name: "relay", value: "wss://relay.example.com/"),
            Tag(name: "challenge", value: "some-challenge-string")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "")
        XCTAssertEqual(event.signature, "b27181e0b72872c463ac75ebf3ad2c2502696d81551bbae6b2a391c67614daf2e321eb5ab724b04520b26fcf7a4c9823fefdb47b10d66c088db44162ba9c1291")
    }

}
