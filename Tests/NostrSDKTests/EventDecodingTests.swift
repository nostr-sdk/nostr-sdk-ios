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
        XCTAssertEqual(event.rawUserMetadata["display_name"] as? String, "Cameri 🦦⚡️")
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

    func testDecodeSetMetadataWithEmptyWebsite() throws {

        let event: SetMetadataEvent = try decodeFixture(filename: "set_metadata_alternate")

        XCTAssertEqual(event.id, "2883f411daaef3370f87dc4456fbe1184ab50ec97013249d7cdda4b8938d0b0a")
        XCTAssertEqual(event.pubkey, "58c741aa630c2da35a56a77c1d05381908bd10504fdd2d8b43f725efa6d23196")
        XCTAssertEqual(event.createdAt, 1676405699)
        XCTAssertEqual(event.kind, .setMetadata)
        XCTAssertEqual(event.tags, [])
        XCTAssertTrue(event.content.hasPrefix("{\"website\":\"\",\"nip05\":"))
        XCTAssertEqual(event.signature, "6f12e0090940bf923d96e9c1dce134c1c16c5fdb1e79efff3ed791bb6ff985b4dda609dc85e1ad15c752c6c5f4cbbf8949068731e1b881ac13b2eb1ce59fc578")

        // access metadata properties from raw dictionary
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "gladstein")
        XCTAssertEqual(event.rawUserMetadata["display_name"] as? String, "gladstein")
        XCTAssertEqual(event.rawUserMetadata["nip05"] as? String, "gladstein@nostrplebs.com")

        // access metadata properties from decoded object
        let userMetadata = try XCTUnwrap(event.userMetadata)
        XCTAssertEqual(userMetadata.name, "gladstein")
        XCTAssertEqual(userMetadata.about, "")
        XCTAssertNil(userMetadata.website)
        XCTAssertEqual(userMetadata.nostrAddress, "gladstein@nostrplebs.com")
    }

    func testDecodeSetMetadataWithCustomEmojis() throws {

        let event: SetMetadataEvent = try decodeFixture(filename: "set_metadata_custom_emojis")

        XCTAssertEqual(event.id, "290e0e02411669d8c6f31b95259020458bb1ad43cec8a4fdf87e5c8628ab3e54")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1699769361)
        XCTAssertEqual(event.kind, .setMetadata)
        XCTAssertEqual(event.tags, [Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]), Tag(name: .emoji, value: "apple", otherParameters: ["https://nostrsdk.com/apple.png"])])
        XCTAssertTrue(event.content.hasPrefix("{\"banner\":\"https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.signature, "9039249cca3b29208fade093a96c7929fa944dfe566ae77933efe738de75852d67e93cbe3c9321dbe95cabb705435071a5ce3116adadc135e493f5939e2e664c")

        // access metadata properties from raw dictionary
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.rawUserMetadata["display_name"] as? String, "Nostr SDK Display Name")
        XCTAssertEqual(event.rawUserMetadata["about"] as? String, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.rawUserMetadata["website"] as? String, "https://github.com/nostr-sdk/nostr-sdk-ios")
        XCTAssertEqual(event.rawUserMetadata["nip05"] as? String, "test@nostr.com")
        XCTAssertEqual(event.rawUserMetadata["picture"] as? String, "https://nostrsdk.com/picture.png")
        XCTAssertEqual(event.rawUserMetadata["banner"] as? String, "https://nostrsdk.com/banner.png")

        // access metadata properties from decoded object
        let userMetadata = try XCTUnwrap(event.userMetadata)
        XCTAssertEqual(userMetadata.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(userMetadata.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(userMetadata.website, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(userMetadata.nostrAddress, "test@nostr.com")
        XCTAssertEqual(userMetadata.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(userMetadata.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
    }

    func testDecodeTextNote() throws {

        let event: TextNoteEvent = try decodeFixture(filename: "text_note")

        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(event.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(event.createdAt, 1682080184)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"),
            .pubkey("f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ")
        XCTAssertEqual(event.signature, "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")
        
        XCTAssertEqual(event.mentionedPubkeys, ["f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"])
        XCTAssertEqual(event.mentionedEventIds, ["93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"])
    }
    
    func testDecodeNoteWithSubject() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_subject")

        XCTAssertEqual(event.id, "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b")
        XCTAssertEqual(event.pubkey, "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2")
        XCTAssertEqual(event.createdAt, 1682080184)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags: [Tag] = [
            .event("93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"),
            .pubkey("f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"),
            Tag(name: .subject, value: "test-subject")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ")
        XCTAssertEqual(event.subject, "test-subject")
        XCTAssertEqual(event.signature, "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")
        
        XCTAssertEqual(event.mentionedPubkeys, ["f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9"])
        XCTAssertEqual(event.mentionedEventIds, ["93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63"])

    }

    func testDecodeNoteWithCustomEmoji() throws {
        let event: TextNoteEvent = try decodeFixture(filename: "text_note_custom_emoji")

        XCTAssertEqual(event.id, "afc6f38482de8600bfbc85d9f1b404a2bbab8a65a3e2eb62f0ce47195e99886b")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1699770458)
        XCTAssertEqual(event.kind, .textNote)

        let expectedTags = [
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]),
            Tag(name: .subject, value: "test-subject")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.content, "Hello world! :ostrich:")
        XCTAssertEqual(event.subject, "test-subject")
        XCTAssertEqual(event.signature, "7a110a5ad3a248985d11dbb90da3f254fa99fbae80bf6e270f36d1c697a6fbf3f6508a5a027f00e2fc9ca81aafdd67c52b09e80c49fa5f7ab3bc8d5836a08601")

        XCTAssertEqual(event.mentionedPubkeys, [])
        XCTAssertEqual(event.mentionedEventIds, [])

    }

    func testDecodeDirectMessage() throws {
        let event: DirectMessageEvent = try decodeFixture(filename: "dm")

        XCTAssertEqual(event.content, "+0V/p6oNtFXAlWVzDTx6wg==?iv=L6gDJ8ei4k1t3lUNgYAahw==")
        XCTAssertEqual(event.id, "a606649e4995a12226902bd38573c21b04732c0835e415d09be6fbe93879b666")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1691768179)
        XCTAssertEqual(event.kind, .directMessage)

        let expectedTags: [Tag] = [
            .pubkey("9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        ]
        XCTAssertEqual(expectedTags, event.tags)

        XCTAssertEqual(try event.decryptedContent(using: Keypair.test.privateKey), "Secret message.")
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
            .pubkey("pubkey1", otherParameters: ["wss://relay1.com", "alice"]),
            .pubkey("pubkey2", otherParameters: ["wss://relay2.com", "bob"])
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

        let firstTag = Tag.pubkey("3efdaebb1d8923ebd99c9e7ace3b4194ab45512e2be79c1b7d68d9243e0d2681")
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
        
        XCTAssertEqual(event.repostedEventPubkey, "reposted-event-pubkey")
        XCTAssertEqual(event.repostedEventId, "test-id")
        XCTAssertEqual(event.repostedEventRelayURL?.absoluteString, "wss://reposted.relay")

        let repostedEvent = try XCTUnwrap(event.repostedEvent)
        
        XCTAssertEqual(repostedEvent.id, "test-id")
        XCTAssertEqual(repostedEvent.kind, .recommendServer)
    }

    func testDecodeReaction() throws {
        let event: ReactionEvent = try decodeFixture(filename: "reaction")

        XCTAssertEqual(event.id, "8a3217770794fabe89adac500dcd5d38966d3ba3cb83fabc97b58135980f76cd")
        XCTAssertEqual(event.pubkey, "2779f3d9f42c7dee17f0e6bcdcf89a8f9d592d19e3b1bbd27ef1cffd1a7f98d1")
        XCTAssertEqual(event.createdAt, 1689029084)
        XCTAssertEqual(event.kind, .reaction)

        let expectedTags: [Tag] = [
            .event("62dcc905c282dd712bbe6b47d2e40feb333f8a0c39899617f4ca37337199ede0"),
            .pubkey("e1ff3bfdd4e40315959b08b4fcc8245eaa514637e1d4ec2ae166b743341be1af")
        ]
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.reactedEventId, "62dcc905c282dd712bbe6b47d2e40feb333f8a0c39899617f4ca37337199ede0")
        XCTAssertEqual(event.reactedEventPubkey, "e1ff3bfdd4e40315959b08b4fcc8245eaa514637e1d4ec2ae166b743341be1af")
        XCTAssertEqual(event.content, "🤙")
        XCTAssertEqual(event.signature, "c0dea5d4612d834e13e0dcfeff71a345f761d868bf27fd5e3fe521b76872d5da3db05375f8739a4bad86189d63720187c08170827990b113b477437f17e4a906")
    }

    func testDecodeCustomEmojiReaction() throws {
        let event: ReactionEvent = try decodeFixture(filename: "custom_emoji_reaction")

        XCTAssertEqual(event.id, "342439c681a0db193992d144c38fce09deaa49e5d441fea6561175982f518f7d")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1699768152)
        XCTAssertEqual(event.kind, .reaction)

        let expectedTags: [Tag] = [
            .event("dc0e8b27b37ec7854ec0d5b24c39901a8cf933be3b420ca3cee6242279f54a48"),
            .pubkey("9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"),
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"])
        ]
        let imageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        XCTAssertEqual(event.customEmojis, [CustomEmoji(shortcode: "ostrich", imageURL: imageURL)])
        XCTAssertEqual(event.tags, expectedTags)
        XCTAssertEqual(event.reactedEventId, "dc0e8b27b37ec7854ec0d5b24c39901a8cf933be3b420ca3cee6242279f54a48")
        XCTAssertEqual(event.reactedEventPubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.content, ":ostrich:")
        XCTAssertEqual(event.signature, "eb20aaff71b309b386ed12a92208fd6a8322b66585331d039d63219c0724752a2ffee211ed99d1dd370f601282f0d3c49c36a28ac4252ee4d0f3f1ce0de06abb")
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

    func testDecodeDateBasedCalendarEvent() throws {
        let event: DateBasedCalendarEvent = try decodeFixture(filename: "date_based_calendar_event")

        XCTAssertEqual(event.id, "a87228880982599ed0f83411e8ea4f6714f35961f32b2274994897c218ad171d")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702832309)
        XCTAssertEqual(event.kind, .dateBasedCalendarEvent)
        XCTAssertEqual(event.identifier, "06E43CF4-D253-4AF9-807A-96FDA4763FF4")
        XCTAssertEqual(event.title, "Nostrica")
        XCTAssertEqual(event.startDate, TimeOmittedDate(year: 2023, month: 3, day: 19))
        XCTAssertEqual(event.endDate, TimeOmittedDate(year: 2023, month: 3, day: 21))
        XCTAssertEqual(event.locations, ["Awake, C. Garcias, Provincia de Puntarenas, Uvita, 60504, Costa Rica", "YouTube"])
        XCTAssertEqual(event.geohash, "d1sknt77t3xn")

        let participants = event.participants
        let expectedParticipantPublicKey = Keypair.test.publicKey
        let relayURL = URL(string: "wss://relay.nostrsdk.com")
        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants,
                       [CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "organizer"),
                        CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "attendee")])

        XCTAssertEqual(event.hashtags, ["nostr", "unconference", "nostrica"])

        XCTAssertEqual(event.references, [URL(string: "https://nostrica.com/"), URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit")])

        XCTAssertEqual(event.content, "First Nostr unconference")
        XCTAssertEqual(event.signature, "b1f04510811195f69552dc1aff5033f306b4fdf9e6e7c1ac265438b457932266414bdf1ed9ec0c2c2f22d56bef7e519af5c3bfb974c933fd20037918b95dc65a")
    }

    func testDecodeDeprecatedDateBasedCalendarEvent() throws {
        let event: DateBasedCalendarEvent = try decodeFixture(filename: "date_based_calendar_event_deprecated")

        XCTAssertEqual(event.id, "14ff9ea332268384f9f72e2623371dd8edf8dd6b8f8b7f0b3d3df29317148d95")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1700320160)
        XCTAssertEqual(event.kind, .dateBasedCalendarEvent)
        XCTAssertEqual(event.identifier, "6E28808F-43FD-49FE-8B31-350066FD3886")
        XCTAssertEqual(event.name, "Nostrica")
        XCTAssertEqual(event.startDate, TimeOmittedDate(year: 2023, month: 3, day: 19))
        XCTAssertEqual(event.endDate, TimeOmittedDate(year: 2023, month: 3, day: 21))
        XCTAssertEqual(event.locations, ["Awake, C. Garcias, Provincia de Puntarenas, Uvita, 60504, Costa Rica"])
        XCTAssertEqual(event.geohash, "d1sknt77t3xn")

        let participants = event.participants
        let expectedParticipantPublicKey = Keypair.test.publicKey
        let relayURL = URL(string: "wss://relay.nostrsdk.com")
        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants,
                       [CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "organizer"),
                        CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "attendee")])

        XCTAssertEqual(event.hashtags, ["nostr", "unconference", "nostrica"])

        XCTAssertEqual(event.references, [URL(string: "https://nostrica.com/"), URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit")])

        XCTAssertEqual(event.content, "First Nostr unconference")
        XCTAssertEqual(event.signature, "5cd7174dff637af03b66f46a6ccc19b526d1fdc987583e6c6ced8fd7b2ce56f37510e989b7037dbf75d84cdac5256275e255e97c6ef42534613f2af78f5925dd")
    }

    func testDecodeTimeBasedCalendarEvent() throws {
        let event: TimeBasedCalendarEvent = try decodeFixture(filename: "time_based_calendar_event")

        XCTAssertEqual(event.id, "818854c3ff09ac5a2c538cba81d911e59f929dcc5531f61ac92278093d101f1b")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1702833417)
        XCTAssertEqual(event.kind, .timeBasedCalendarEvent)
        XCTAssertEqual(event.identifier, "798F1F69-1DE3-4623-8DCC-FAF9B773E72B")
        XCTAssertEqual(event.title, "Flight from New York (JFK) to San José, Costa Rica (SJO)")
        XCTAssertEqual(event.startTimestamp, Date(timeIntervalSince1970: 1679062500))
        XCTAssertEqual(event.endTimestamp, Date(timeIntervalSince1970: 1679067720))
        XCTAssertEqual(event.startTimeZone, TimeZone(identifier: "America/New_York"))
        XCTAssertEqual(event.endTimeZone, TimeZone(identifier: "America/Costa_Rica"))
        XCTAssertEqual(event.locations, ["John F. Kennedy International Airport, Queens, NY 11430, USA"])
        XCTAssertEqual(event.geohash, "dr5x1p57bg9e")

        let participants = event.participants
        let expectedParticipantPublicKey = Keypair.test.publicKey
        let relayURL = URL(string: "wss://relay.nostrsdk.com")
        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants,
                       [CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "organizer"),
                        CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "attendee")])

        XCTAssertEqual(event.hashtags, ["flights", "costarica"])

        XCTAssertEqual(event.references, [URL(string: "https://nostrica.com/"), URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit")])

        XCTAssertEqual(event.content, "Flight to Nostrica")
        XCTAssertEqual(event.signature, "c2aa36b07c4df050d637dd2be770767c67621e7d87179f9f1e5ef118543328ed238afbd6b33317a61178205b75e6ecb0a61ea4cf6c657a7da0e4cea4842d4c01")
    }

    func testDecodeDeprecatedTimeBasedCalendarEvent() throws {
        let event: TimeBasedCalendarEvent = try decodeFixture(filename: "time_based_calendar_event_deprecated")

        XCTAssertEqual(event.id, "091455f5c9509655e3a4f68f98e807349ac0b5525506b22978566a0bb0f3ced1")
        XCTAssertEqual(event.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(event.createdAt, 1700320270)
        XCTAssertEqual(event.kind, .timeBasedCalendarEvent)
        XCTAssertEqual(event.identifier, "9CD6DE6C-F8D9-44FB-B948-CB5A42434F8F")
        XCTAssertEqual(event.name, "Flight from New York (JFK) to San José, Costa Rica (SJO)")
        XCTAssertEqual(event.startTimestamp, Date(timeIntervalSince1970: 1679062500))
        XCTAssertEqual(event.endTimestamp, Date(timeIntervalSince1970: 1679067720))
        XCTAssertEqual(event.startTimeZone, TimeZone(identifier: "America/New_York"))
        XCTAssertEqual(event.endTimeZone, TimeZone(identifier: "America/Costa_Rica"))
        XCTAssertEqual(event.locations, ["John F. Kennedy International Airport, Queens, NY 11430, USA"])
        XCTAssertEqual(event.geohash, "dr5x1p57bg9e")

        let participants = event.participants
        let expectedParticipantPublicKey = Keypair.test.publicKey
        let relayURL = URL(string: "wss://relay.nostrsdk.com")
        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants,
                       [CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "organizer"),
                        CalendarEventParticipant(pubkey: expectedParticipantPublicKey, relayURL: relayURL, role: "attendee")])

        XCTAssertEqual(event.hashtags, ["flights", "costarica"])

        XCTAssertEqual(event.references, [URL(string: "https://nostrica.com/"), URL(string: "https://docs.google.com/document/d/1Gsv09gfuwhqhQerIkxeYQ7iOTjOHUC5oTnL2KKyHpR8/edit")])

        XCTAssertEqual(event.content, "Flight to Nostrica")
        XCTAssertEqual(event.signature, "57cdb0735645a7ff7112c2d863c425a75e82b540412117609c1c32bee833622a82acacd836b2790f0f08082e2700cdf1ac363c2aae1db87e613824fea2907845")
    }

    func testDecodeCalendar() throws {
        let event: CalendarNostrEvent = try decodeFixture(filename: "calendar")

        XCTAssertEqual(event.id, "1dc8b913d9d4f50a71182dc9232996d6fbc69e8c955866e43ef2c2e35185bbfa")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .calendar)
        XCTAssertEqual(event.signature, "24c397594fe6d8b5590ce4e7163990f4269bc515d1181487d722730144ac32e8439954d66e88f3232ad807e8d06f01791b5856ae249b139b1469df58045252a9")
        XCTAssertEqual(event.createdAt, 1703052671)
        XCTAssertEqual(event.identifier, "family-calendar")
        XCTAssertEqual(event.title, "Family Calendar")
        XCTAssertEqual(event.content, "All family events.")

        let pubkey = try XCTUnwrap(PublicKey(hex: "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"))
        XCTAssertEqual(
            event.calendarEventsCoordinates,
            [
                EventCoordinates(kind: .dateBasedCalendarEvent, pubkey: pubkey, identifier: "D5EB0A5A-0B36-44DB-95C3-DB51799894E6"),
                EventCoordinates(kind: .timeBasedCalendarEvent, pubkey: pubkey, identifier: "1D355ED3-A45D-41A9-B3A5-709211794EFB")
            ]
        )
    }

    func testDecodeCalendarEventRSVP() throws {
        let event: CalendarEventRSVP = try decodeFixture(filename: "calendar_event_rsvp")

        XCTAssertEqual(event.id, "1ec761bbeacd17f4ca961668725ea85a9001a0f56da37eb424856a9de1188a2d")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .calendarEventRSVP)
        XCTAssertEqual(event.signature, "21c58b1d759c6470cbb1931653d3c44cbc24c87be9632b794b2c4bb3a0abd27117dd9e3c8c90cf669a6f0d8204f20f92c2a20ed832a54d999d010402d2b1aa9a")
        XCTAssertEqual(event.createdAt, 1703052002)
        XCTAssertEqual(event.content, "Don't forget your skates!")
        XCTAssertEqual(event.identifier, "hockey-practice-rsvp")
        XCTAssertEqual(event.status, .accepted)
        XCTAssertEqual(event.freebusy, .busy)

        let pubkey = try XCTUnwrap(PublicKey(hex: "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"))
        XCTAssertEqual(event.calendarEventCoordinates, EventCoordinates(kind: .dateBasedCalendarEvent, pubkey: pubkey, identifier: "D1D48740-2CF8-4483-B5F0-1E83F6D7EC50"))
    }

    func testDecodeMuteListEvent() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        
        XCTAssertEqual(event.id, "acfc1402d926b88a26dffc94162e399f2b35d7c7503a1fde2f2cc6d11d33ad88")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.kind, .muteList)
        
        XCTAssertTrue(event.tags.contains(.pubkey("07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f")))
        XCTAssertTrue(event.tags.contains(.hashtag("testing")))
        XCTAssertTrue(event.tags.contains(.hashtag("test2")))
        
        let secretTags = event.privateTags(using: .test)
        XCTAssertTrue(secretTags.contains(.pubkey("6e468422dfb74a5738702a8823b9b28168abab8655faacb6853cd0ee15deee93")))
        XCTAssertTrue(secretTags.contains(.hashtag("sportsball")))
        XCTAssertTrue(secretTags.contains(.hashtag("footstr")))
        
        XCTAssertEqual(event.privateHashtags(using: .test), ["sportsball", "footstr"])
    }
}
