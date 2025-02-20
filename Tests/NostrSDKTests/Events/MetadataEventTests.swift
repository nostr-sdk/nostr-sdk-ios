//
//  MetadataEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class MetadataEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateMetadataEvent() throws {
        let ostrichImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        let appleImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/apple.png"))

        let customEmojis = [
            try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: ostrichImageURL)),
            try XCTUnwrap(CustomEmoji(shortcode: "apple", imageURL: appleImageURL))
        ]

        let event = try MetadataEvent.Builder()
            .name("Nostr SDK Test :ostrich:")
            .displayName("Nostr SDK Display Name")
            .about("I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
            .websiteURL(try XCTUnwrap(URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios")))
            .nostrAddress("test@nostr.com")
            .pictureURL(try XCTUnwrap(URL(string: "https://nostrsdk.com/picture.png")))
            .bannerPictureURL(try XCTUnwrap(URL(string: "https://nostrsdk.com/banner.png")))
            .isBot(true)
            .lightningURLString("LNURL1234567890")
            .lightningAddress("satoshi@bitcoin.org")
            .appendTags(Tag(name: "foo", value: "string"))
            .appendTags(Tag(name: "bool", value: "true"))
            .appendTags(Tag(name: "number", value: "123"))
            .customEmojis(customEmojis)
            .build(signedBy: .test)

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .metadata, pubkey: Keypair.test.publicKey))

        XCTAssertEqual(event.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.websiteURL, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.isBot, true)
        XCTAssertEqual(event.lightningURLString, "LNURL1234567890")
        XCTAssertEqual(event.lightningAddress, "satoshi@bitcoin.org")
        XCTAssertEqual(event.userMetadata?.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.userMetadata?.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.userMetadata?.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.userMetadata?.website, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.userMetadata?.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.userMetadata?.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.userMetadata?.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.userMetadata?.isBot, true)
        XCTAssertEqual(event.userMetadata?.lightningURLString, "LNURL1234567890")
        XCTAssertEqual(event.userMetadata?.lightningAddress, "satoshi@bitcoin.org")
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.rawUserMetadata["lud16"] as? String, "satoshi@bitcoin.org")
        XCTAssertEqual(event.customEmojis, customEmojis)
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        let expectedTags = [
            Tag(name: "name", value: "Nostr SDK Test :ostrich:"),
            Tag(name: "display_name", value: "Nostr SDK Display Name"),
            Tag(name: "about", value: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:"),
            Tag(name: "website", value: "https://github.com/nostr-sdk/nostr-sdk-ios"),
            Tag(name: "nip05", value: "test@nostr.com"),
            Tag(name: "picture", value: "https://nostrsdk.com/picture.png"),
            Tag(name: "banner", value: "https://nostrsdk.com/banner.png"),
            Tag(name: "bot", value: "true"),
            Tag(name: "lud06", value: "LNURL1234567890"),
            Tag(name: "lud16", value: "satoshi@bitcoin.org"),
            Tag(name: "foo", value: "string"),
            Tag(name: "bool", value: "true"),
            Tag(name: "number", value: "123"),
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]),
            Tag(name: .emoji, value: "apple", otherParameters: ["https://nostrsdk.com/apple.png"])
        ]
        print("Actual:")
        print(event.tags)
        print("Expected:")
        print(expectedTags)
        XCTAssertEqual(event.tags, expectedTags)

        try verifyEvent(event)
    }

    func testCreateMetadataEventDeprecatedStringifiedJSON() throws {
        let meta = UserMetadata(name: "Nostr SDK Test :ostrich:",
                                displayName: "Nostr SDK Display Name",
                                about: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:",
                                website: URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"),
                                nostrAddress: "test@nostr.com",
                                pictureURL: URL(string: "https://nostrsdk.com/picture.png"),
                                bannerPictureURL: URL(string: "https://nostrsdk.com/banner.png"),
                                isBot: true,
                                lightningURLString: "LNURL1234567890",
                                lightningAddress: "satoshi@bitcoin.org")

        let rawUserMetadata: [String: Any] = [
            "foo": "string",
            "bool": true,
            "number": 123,
            "name": "This field should be ignored.",
            "lud16": "should@be.ignored"
        ]

        let ostrichImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        let appleImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/apple.png"))

        let customEmojis = [
            try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: ostrichImageURL)),
            try XCTUnwrap(CustomEmoji(shortcode: "apple", imageURL: appleImageURL))
        ]

        let event = try XCTUnwrap(
            MetadataEvent.Builder()
                .userMetadata(meta, merging: rawUserMetadata)
                .customEmojis(customEmojis)
                .build(signedBy: .test)
        )

        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .metadata, pubkey: Keypair.test.publicKey))

        XCTAssertEqual(event.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.websiteURL, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.isBot, true)
        XCTAssertEqual(event.lightningURLString, "LNURL1234567890")
        XCTAssertEqual(event.lightningAddress, "satoshi@bitcoin.org")
        XCTAssertEqual(event.userMetadata?.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.userMetadata?.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.userMetadata?.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.userMetadata?.website, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.userMetadata?.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.userMetadata?.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.userMetadata?.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.userMetadata?.isBot, true)
        XCTAssertEqual(event.userMetadata?.lightningURLString, "LNURL1234567890")
        XCTAssertEqual(event.userMetadata?.lightningAddress, "satoshi@bitcoin.org")
        XCTAssertEqual(event.rawUserMetadata["foo"] as? String, "string")
        XCTAssertEqual(event.rawUserMetadata["bool"] as? Bool, true)
        XCTAssertEqual(event.rawUserMetadata["number"] as? Int, 123)
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.rawUserMetadata["lud16"] as? String, "satoshi@bitcoin.org")
        XCTAssertEqual(event.customEmojis, customEmojis)
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        let expectedTags = [
            Tag(name: "about", value: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:"),
            Tag(name: "banner", value: "https://nostrsdk.com/banner.png"),
            Tag(name: "bool", value: "true"),
            Tag(name: "bot", value: "true"),
            Tag(name: "display_name", value: "Nostr SDK Display Name"),
            Tag(name: "foo", value: "string"),
            Tag(name: "lud06", value: "LNURL1234567890"),
            Tag(name: "lud16", value: "satoshi@bitcoin.org"),
            Tag(name: "name", value: "Nostr SDK Test :ostrich:"),
            Tag(name: "nip05", value: "test@nostr.com"),
            Tag(name: "number", value: "123"),
            Tag(name: "picture", value: "https://nostrsdk.com/picture.png"),
            Tag(name: "website", value: "https://github.com/nostr-sdk/nostr-sdk-ios"),
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]),
            Tag(name: .emoji, value: "apple", otherParameters: ["https://nostrsdk.com/apple.png"])
        ]
        XCTAssertEqual(event.tags, expectedTags)

        try verifyEvent(event)
    }

    func testCreateMetadataEventCreatingDeprecated() throws {
        let meta = UserMetadata(name: "Nostr SDK Test :ostrich:",
                                displayName: "Nostr SDK Display Name",
                                about: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:",
                                website: URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"),
                                nostrAddress: "test@nostr.com",
                                pictureURL: URL(string: "https://nostrsdk.com/picture.png"),
                                bannerPictureURL: URL(string: "https://nostrsdk.com/banner.png"),
                                isBot: true,
                                lightningURLString: "LNURL1234567890",
                                lightningAddress: "satoshi@bitcoin.org")

        let rawUserMetadata: [String: Any] = [
            "foo": "string",
            "bool": true,
            "number": 123,
            "name": "This field should be ignored.",
            "lud16": "should@be.ignored"
        ]

        let ostrichImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        let appleImageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/apple.png"))

        let customEmojis = [
            try XCTUnwrap(CustomEmoji(shortcode: "ostrich", imageURL: ostrichImageURL)),
            try XCTUnwrap(CustomEmoji(shortcode: "apple", imageURL: appleImageURL))
        ]

        let event = try metadataEvent(withUserMetadata: meta, rawUserMetadata: rawUserMetadata, customEmojis: customEmojis, signedBy: .test)
        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .metadata, pubkey: Keypair.test.publicKey))

        XCTAssertEqual(event.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.websiteURL, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.isBot, true)
        XCTAssertEqual(event.lightningURLString, "LNURL1234567890")
        XCTAssertEqual(event.lightningAddress, "satoshi@bitcoin.org")
        XCTAssertEqual(event.userMetadata?.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.userMetadata?.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.userMetadata?.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.userMetadata?.website, URL(string: "https://github.com/nostr-sdk/nostr-sdk-ios"))
        XCTAssertEqual(event.userMetadata?.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.userMetadata?.pictureURL, URL(string: "https://nostrsdk.com/picture.png"))
        XCTAssertEqual(event.userMetadata?.bannerPictureURL, URL(string: "https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.userMetadata?.isBot, true)
        XCTAssertEqual(event.userMetadata?.lightningURLString, "LNURL1234567890")
        XCTAssertEqual(event.userMetadata?.lightningAddress, "satoshi@bitcoin.org")
        XCTAssertEqual(event.rawUserMetadata["foo"] as? String, "string")
        XCTAssertEqual(event.rawUserMetadata["bool"] as? Bool, true)
        XCTAssertEqual(event.rawUserMetadata["number"] as? Int, 123)
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.rawUserMetadata["lud16"] as? String, "satoshi@bitcoin.org")
        XCTAssertEqual(event.customEmojis, customEmojis)
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)

        let expectedTags = [
            Tag(name: "about", value: "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:"),
            Tag(name: "banner", value: "https://nostrsdk.com/banner.png"),
            Tag(name: "bool", value: "true"),
            Tag(name: "bot", value: "true"),
            Tag(name: "display_name", value: "Nostr SDK Display Name"),
            Tag(name: "foo", value: "string"),
            Tag(name: "lud06", value: "LNURL1234567890"),
            Tag(name: "lud16", value: "satoshi@bitcoin.org"),
            Tag(name: "name", value: "Nostr SDK Test :ostrich:"),
            Tag(name: "nip05", value: "test@nostr.com"),
            Tag(name: "number", value: "123"),
            Tag(name: "picture", value: "https://nostrsdk.com/picture.png"),
            Tag(name: "website", value: "https://github.com/nostr-sdk/nostr-sdk-ios"),
            Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]),
            Tag(name: .emoji, value: "apple", otherParameters: ["https://nostrsdk.com/apple.png"])
        ]
        XCTAssertEqual(event.tags, expectedTags)

        try verifyEvent(event)
    }

    func testDecodeMetadata() throws {

        let event: MetadataEvent = try decodeFixture(filename: "metadata")

        XCTAssertEqual(event.id, "d214c914b0ab49ec919fa5f60fabf746f421e432d96f941bd2573e4d22e36b51")
        XCTAssertEqual(event.pubkey, "00000000827ffaa94bfea288c3dfce4422c794fbb96625b6b31e9049f729d700")
        XCTAssertEqual(event.createdAt, 1684370291)
        XCTAssertEqual(event.kind, .metadata)
        XCTAssertNotEqual(event.tags, [])
        XCTAssertFalse(event.content.isEmpty)
        XCTAssertEqual(event.signature, "7bb7f031fbf41f49eeb44fdfb061bc8d143197d33fae8d29b017709adf2b17c76e78ccb2ee128ee93d0661cad4c626a747d48a178745c94944a693ff31ea7619")

        // access metadata tags
        XCTAssertEqual(event.name, "cameri")
        XCTAssertEqual(event.about, "@HodlWithLedn. All opinions are my own.\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.")
        XCTAssertEqual(event.websiteURL?.absoluteString, "https://primal.net/cameri")
        XCTAssertEqual(event.nostrAddress, "cameri@elder.nostr.land")
        XCTAssertEqual(
            event.pictureURL?.absoluteString,
            "https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg"
        )
        XCTAssertEqual(
            event.bannerPictureURL?.absoluteString,
            "https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif"
        )
        XCTAssertEqual(event.lightningAddress, "cameri@getalby.com")

        XCTAssertFalse(event.rawUserMetadata.isEmpty)
        XCTAssertNotNil(event.userMetadata)

    }

    func testDecodeMetadataJSONStringified() throws {

        let event: MetadataEvent = try decodeFixture(filename: "metadata_json_stringified")

        XCTAssertEqual(event.id, "d214c914b0ab49ec919fa5f60fabf746f421e432d96f941bd2573e4d22e36b51")
        XCTAssertEqual(event.pubkey, "00000000827ffaa94bfea288c3dfce4422c794fbb96625b6b31e9049f729d700")
        XCTAssertEqual(event.createdAt, 1684370291)
        XCTAssertEqual(event.kind, .metadata)
        XCTAssertEqual(event.tags, [])
        XCTAssertTrue(event.content.hasPrefix("{\"banner\":\"https://nostr.build/i/nostr.build"))
        XCTAssertEqual(event.signature, "7bb7f031fbf41f49eeb44fdfb061bc8d143197d33fae8d29b017709adf2b17c76e78ccb2ee128ee93d0661cad4c626a747d48a178745c94944a693ff31ea7619")

        // access metadata tags
        XCTAssertEqual(event.name, "cameri")
        XCTAssertEqual(event.about, "@HodlWithLedn. All opinions are my own.\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.")
        XCTAssertEqual(event.websiteURL?.absoluteString, "https://primal.net/cameri")
        XCTAssertEqual(event.nostrAddress, "cameri@elder.nostr.land")
        XCTAssertEqual(
            event.pictureURL?.absoluteString,
            "https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg"
        )
        XCTAssertEqual(
            event.bannerPictureURL?.absoluteString,
            "https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif"
        )
        XCTAssertEqual(event.lightningAddress, "cameri@getalby.com")

        // access metadata properties from raw dictionary
        XCTAssertEqual(event.rawUserMetadata["name"] as? String, "cameri")
        XCTAssertEqual(event.rawUserMetadata["display_name"] as? String, "Cameri 🦦⚡️")
        XCTAssertEqual(event.rawUserMetadata["about"] as? String, "@HodlWithLedn. All opinions are my own.\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.")
        XCTAssertEqual(event.rawUserMetadata["website"] as? String, "https://primal.net/cameri")
        XCTAssertEqual(event.rawUserMetadata["nip05"] as? String, "cameri@elder.nostr.land")
        XCTAssertEqual(event.rawUserMetadata["picture"] as? String, "https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg")
        XCTAssertEqual(event.rawUserMetadata["banner"] as? String, "https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif")
        XCTAssertEqual(event.rawUserMetadata["lud16"] as? String, "cameri@getalby.com")

        // access metadata properties from decoded object
        let userMetadata = try XCTUnwrap(event.userMetadata)
        XCTAssertEqual(userMetadata.name, "cameri")
        XCTAssertEqual(userMetadata.about, "@HodlWithLedn. All opinions are my own.\nBitcoiner class of 2021. Core Nostr Developer. Author of Nostream. Professional Relay Operator.")
        XCTAssertEqual(userMetadata.website, URL(string: "https://primal.net/cameri"))
        XCTAssertEqual(userMetadata.nostrAddress, "cameri@elder.nostr.land")
        XCTAssertEqual(userMetadata.pictureURL, URL(string: "https://nostr.build/i/9396d5cd901304726883aea7363543f121e1d53964dd3149cadecd802608aebe.jpg"))
        XCTAssertEqual(userMetadata.bannerPictureURL, URL(string: "https://nostr.build/i/nostr.build_90a51a2e50c9f42288260d01b3a2a4a1c7a9df085423abad7809e76429da7cdc.gif"))
        XCTAssertEqual(userMetadata.lightningAddress, "cameri@getalby.com")
    }

    func testDecodeMetadataJSONStringifiedWithEmptyWebsite() throws {

        let event: MetadataEvent = try decodeFixture(filename: "metadata_json_stringified_alternate")

        XCTAssertEqual(event.id, "2883f411daaef3370f87dc4456fbe1184ab50ec97013249d7cdda4b8938d0b0a")
        XCTAssertEqual(event.pubkey, "58c741aa630c2da35a56a77c1d05381908bd10504fdd2d8b43f725efa6d23196")
        XCTAssertEqual(event.createdAt, 1676405699)
        XCTAssertEqual(event.kind, .metadata)
        XCTAssertEqual(event.tags, [])
        XCTAssertTrue(event.content.hasPrefix("{\"website\":\"\",\"nip05\":"))
        XCTAssertEqual(event.signature, "6f12e0090940bf923d96e9c1dce134c1c16c5fdb1e79efff3ed791bb6ff985b4dda609dc85e1ad15c752c6c5f4cbbf8949068731e1b881ac13b2eb1ce59fc578")

        // access metadata tags
        XCTAssertEqual(event.name, "gladstein")
        XCTAssertEqual(event.displayName, "gladstein")
        XCTAssertEqual(event.about, "")
        XCTAssertNil(event.websiteURL)
        XCTAssertEqual(event.nostrAddress, "gladstein@nostrplebs.com")

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

    func testDecodeMetadataWithCustomEmojis() throws {

        let event: MetadataEvent = try decodeFixture(filename: "metadata_custom_emojis")

        XCTAssertEqual(event.id, "290e0e02411669d8c6f31b95259020458bb1ad43cec8a4fdf87e5c8628ab3e54")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1699769361)
        XCTAssertEqual(event.kind, .metadata)
        XCTAssertEqual(event.tags, [Tag(name: .emoji, value: "ostrich", otherParameters: ["https://nostrsdk.com/ostrich.png"]), Tag(name: .emoji, value: "apple", otherParameters: ["https://nostrsdk.com/apple.png"])])
        XCTAssertTrue(event.content.hasPrefix("{\"banner\":\"https://nostrsdk.com/banner.png"))
        XCTAssertEqual(event.signature, "9039249cca3b29208fade093a96c7929fa944dfe566ae77933efe738de75852d67e93cbe3c9321dbe95cabb705435071a5ce3116adadc135e493f5939e2e664c")

        // access metadata tags
        XCTAssertEqual(event.name, "Nostr SDK Test :ostrich:")
        XCTAssertEqual(event.displayName, "Nostr SDK Display Name")
        XCTAssertEqual(event.about, "I'm a test account. I'm used to test the Nostr SDK for Apple platforms. :apple:")
        XCTAssertEqual(event.websiteURL?.absoluteString, "https://github.com/nostr-sdk/nostr-sdk-ios")
        XCTAssertEqual(event.nostrAddress, "test@nostr.com")
        XCTAssertEqual(event.pictureURL?.absoluteString, "https://nostrsdk.com/picture.png")
        XCTAssertEqual(event.bannerPictureURL?.absoluteString, "https://nostrsdk.com/banner.png")

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

}
