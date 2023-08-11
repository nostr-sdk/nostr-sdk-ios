//
//  EventDecodingTests.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

@testable import NostrSDK
import XCTest

final class EventDecodingTests: XCTestCase, FixtureLoading {

    func testDecodeSetMetadata() throws {

        let event: SetMetadataEvent = try decodeFixture(filename: "set_metadata")

        XCTAssertEqual(event.id, "d214c914b0ab49ec919fa5f60fabf746f421e432d96f941bd2573e4d22e36b51")
        XCTAssertEqual(event.pubkey, "00000000827ffaa94bfea288c3dfce4422c794fbb96625b6b31e9049f729d700")
        XCTAssertEqual(event.createdAt, 1684370291)
        XCTAssertEqual(event.kind, .setMetadata)
        XCTAssertEqual(event.tags, [])
        XCTAssertTrue(event.content.hasPrefix("{\"banner\":\"https://nostr.build/i/nostr.build"))
        XCTAssertEqual(event.signature, "7bb7f031fbf41f49eeb44fdfb061bc8d143197d33fae8d29b017709adf2b17c76e78ccb2ee128ee93d0661cad4c626a747d48a178745c94944a693ff31ea7619")
        
        // access metadata properties from raw dictionary
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "cameri")
        XCTAssertEqual(event.rawUserMetadata["about"] as? String, "@HodlWithLedn. All opinions are my own.\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.")
        XCTAssertEqual(event.rawUserMetadata["website"] as? String, "https://primal.net/cameri")
        XCTAssertEqual(event.rawUserMetadata["nip05"] as? String, "cameri@elder.nostr.land")
        XCTAssertEqual(event.rawUserMetadata["picture"] as? String, "https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg")
        XCTAssertEqual(event.rawUserMetadata["banner"] as? String, "https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif")
        
        // access metadata properties from decoded object
        let userMetadata = try XCTUnwrap(event.userMetadata)
        XCTAssertEqual(userMetadata.name, "cameri")
        XCTAssertEqual(userMetadata.about, "@HodlWithLedn. All opinions are my own.\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.")
        XCTAssertEqual(userMetadata.website, URL(string: "https://primal.net/cameri"))
        XCTAssertEqual(userMetadata.nostrAddress, "cameri@elder.nostr.land")
        XCTAssertEqual(userMetadata.pictureURL, URL(string: "https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg"))
        XCTAssertEqual(userMetadata.bannerPictureURL, URL(string: "https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif"))
    }

    func testDecodeTextNote() throws {

        let event: TextNoteEvent = try decodeFixture(filename: "text_note")

        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(event.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(event.createdAt, 1682080184)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags = [
            Tag(name: .event, value: "93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"),
            Tag(name: .pubkey, value: "f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ")
        XCTAssertEqual(event.signature, "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")
        
        XCTAssertEqual(event.mentionedPubkeys, ["f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"])
        XCTAssertEqual(event.mentionedEventIds, ["93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"])
    }

    func testDecodeDirectMessage() throws {
        let event: DirectMessageEvent = try decodeFixture(filename: "dm")

        XCTAssertEqual(event.content, "+0V/p6oNtFXAlWVzDTx6wg==?iv=L6gDJ8ei4k1t3lUNgYAahw==")
        XCTAssertEqual(event.id, "a606649e4995a12226902bd38573c21b04732c0835e415d09be6fbe93879b666")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1691768179)
        XCTAssertEqual(event.kind, .directMessage)

        let expectedTags = [
            Tag(name: .pubkey, value: "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        ]
        XCTAssertEqual(expectedTags, event.tags)

        XCTAssertEqual(try event.decryptedContent(keypair: Keypair.test), "Secret message.")
    }
    
    func testDecodeRecommendServer() throws {
        
        let event: RecommendServerEvent = try decodeFixture(filename: "recommend_server")
        
        XCTAssertEqual(event.id, "test-id")
        XCTAssertEqual(event.pubkey, "test-pubkey")
        XCTAssertEqual(event.createdAt, 1683799330)
        XCTAssertEqual(event.kind, .recommendServer)
        XCTAssertEqual(event.tags, [])
        XCTAssertEqual(event.content, "wss://nostr.relay")
        XCTAssertEqual(event.signature, "test-signature")

        XCTAssertEqual(event.relayURL, URL(string: "wss://nostr.relay"))
    }
    
    func testDecodeContactList() throws {

        let event: ContactListEvent = try decodeFixture(filename: "contact_list")
        
        XCTAssertEqual(event.id, "test-id")
        XCTAssertEqual(event.pubkey, "test-pubkey")
        XCTAssertEqual(event.createdAt, 1684817569)
        XCTAssertEqual(event.kind, .contactList)
        
        let expectedTags: [Tag] = [
            Tag(name: .pubkey, value: "pubkey1", otherParameters: ["wss://relay1.com", "alice"]),
            Tag(name: .pubkey, value: "pubkey2", otherParameters: ["wss://relay2.com", "bob"])
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.signature, "hex-signature")
    }
    
    func testDecodeContactListWithRelays() throws {
        let event: ContactListEvent = try decodeFixture(filename: "contact_list_with_relays")

        let expectedPubkeys = [
            "3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681",
            "07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f",
            "020f2d21ae09bf35fcdfb65decf1478b846f5f728ab30c5eaabcd6d081a81c3e",
            "58c741aa630c2da35a56a77c1d05381908bd10504fdd2d8b43f725efa6d23196",
            "59fbee7369df7713dbbfa9bbdb0892c62eba929232615c6ff2787da384cb770f"
        ]

        XCTAssertEqual(event.contactPubkeys, expectedPubkeys)

        let firstTag = Tag(name: .pubkey, value: "3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681")
        XCTAssertEqual(event.contactPubkeyTags.first, firstTag)

        let expectedRelays = [
            "wss://relay.damus.io": RelayPermissions(read: true, write: true),
            "wss://relay.current.fyi": RelayPermissions(read: false, write: true),
            "wss://eden.nostr.land": RelayPermissions(read: true, write: true),
            "wss://relay.snort.social": RelayPermissions(read: true, write: false),
            "wss://nos.lol": RelayPermissions(read: true, write: true)
        ]
        
        XCTAssertEqual(event.relays, expectedRelays)
    }
    
    func testDecodeRepost() throws {
        
        let event: TextNoteRepostEvent = try decodeFixture(filename: "repost")

        XCTAssertEqual(event.id, "9353c66d99d600f51b9b1f309b804d2156facd227d643eb513eb8c508498da21")
        XCTAssertEqual(event.pubkey, "91c9a5e1a9744114c6fe2d61ae4de82629eaaa0fb52f48288093c7e7e036f832")
        XCTAssertEqual(event.createdAt, 1684817569)
        XCTAssertEqual(event.kind, .repost)

        let expectedTags = [
            Tag(name: .event, value: "6663efd8ffb35325af90a84cb223dc388e9d355abf7319fe5c4c5ca7f37e9a34"),
            Tag(name: .pubkey, value: "33eecd2e2fae31f36c0bdb843d43611426ee5c023889f0401c1b8f5008e59689")
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
        
        XCTAssertEqual(event.repostedEventPubkey, "reposted-event-pubkey")
        XCTAssertEqual(event.repostedEventId, "test-id")
        XCTAssertEqual(event.repostedEventRelayURL, "wss://reposted.relay")
        
        let repostedEvent = try XCTUnwrap(event.repostedEvent)
        
        XCTAssertEqual(repostedEvent.id, "test-id")
        XCTAssertEqual(repostedEvent.kind, .recommendServer)
    }
}
