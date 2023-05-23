//
//  EventDecodingTests.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

@testable import NostrSDK
import XCTest

final class EventDecodingTests: XCTestCase {

    func testDecodeSetMetadata() throws {
        let json = """
              {
                "content": "{\\"banner\\":\\"https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif\\",\\"website\\":\\"https://primal.net/cameri\\",\\"reactions\\":true,\\"damus_donation\\":100,\\"picture\\":\\"https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg\\",\\"nip05\\":\\"cameri@elder.nostr.land\\",\\"lud16\\":\\"cameri@getalby.com\\",\\"display_name\\":\\"Cameri 🦦⚡️\\",\\"about\\":\\"@HodlWithLedn. All opinions are my own.\\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.\\",\\"name\\":\\"cameri\\"}",
                "created_at": 1684370291,
                "id": "d214c914b0ab49ec919fa5f60fabf746f421e432d96f941bd2573e4d22e36b51",
                "kind": 0,
                "pubkey": "00000000827ffaa94bfea288c3dfce4422c794fbb96625b6b31e9049f729d700",
                "sig": "7bb7f031fbf41f49eeb44fdfb061bc8d143197d33fae8d29b017709adf2b17c76e78ccb2ee128ee93d0661cad4c626a747d48a178745c94944a693ff31ea7619",
                "tags": []
              }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))

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
