//
//  EventDecodingTests.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

@testable import NostrSDK
import XCTest

final class EventDecodingTests: XCTestCase {

    func testDecodeTextNote() throws {
        let json = """
              {
                "id": "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b",
                "pubkey": "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2",
                "created_at": 1682080184,
                "kind": 1,
                "tags": [
                  [
                    "e",
                    "93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"
                  ],
                  [
                    "p",
                    "f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"
                  ]
                ],
                "content": "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ",
                "sig": "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09"
              }
            """

        let data = try XCTUnwrap(json.data(using: .utf8))

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
}
