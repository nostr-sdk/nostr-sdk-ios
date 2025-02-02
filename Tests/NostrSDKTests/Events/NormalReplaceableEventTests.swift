//
//  NormalReplaceableEventTests.swift
//
//
//  Created by Terry Yiu on 6/30/24.
//

@testable import NostrSDK
import XCTest

final class NormalReplaceableEventTests: XCTestCase, FixtureLoading, MetadataCoding {

    func testReplaceableEventCoordinates() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let publicKey = try XCTUnwrap(PublicKey(hex: "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340"))
        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .muteList, pubkey: publicKey))
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)
    }

    func testNaddr() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let naddr = try XCTUnwrap(event.naddr())
        XCTAssertEqual(naddr, "naddr1qqqqygyeglukt8wcpsmgysptvyh4g3lzsfyejlanwz2spse2tp0tp9mngqpsgqqqyugqp4hw4t")

        let metadata = try XCTUnwrap(decodedMetadata(from: naddr))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays, [])
    }

    func testShareableEventCoordinates() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates())
        XCTAssertEqual(shareableEventCoordinates, "naddr1qqqqygyeglukt8wcpsmgysptvyh4g3lzsfyejlanwz2spse2tp0tp9mngqpsgqqqyugqp4hw4t")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays, [])
    }

    func testNaddrWithRelays() throws {
        let relay1 = "wss://relay1.com"
        let relay2 = "wss://relay2.com"

        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let naddr = try XCTUnwrap(event.naddr(relayURLStrings: [relay1, relay2]))
        XCTAssertEqual(naddr, "naddr1qqqqzyrhwden5te0wfjkcctexyhxxmmdqyg8wumn8ghj7un9d3shjv3wvdhk6q3qn9rljevamqxrdqjq9dsj74z8u2pynxtlkdcf2qxr9fv9avyhwdqqxpqqqqn3qtqh7yd")

        let metadata = try XCTUnwrap(decodedMetadata(from: naddr))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays?.count, 2)
        XCTAssertEqual(metadata.relays?[0], relay1)
        XCTAssertEqual(metadata.relays?[1], relay2)
    }

    func testShareableEventCoordinatesWithRelays() throws {
        let relay1 = "wss://relay1.com"
        let relay2 = "wss://relay2.com"

        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates(relayURLStrings: [relay1, relay2]))
        XCTAssertEqual(shareableEventCoordinates, "naddr1qqqqzyrhwden5te0wfjkcctexyhxxmmdqyg8wumn8ghj7un9d3shjv3wvdhk6q3qn9rljevamqxrdqjq9dsj74z8u2pynxtlkdcf2qxr9fv9avyhwdqqxpqqqqn3qtqh7yd")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays?.count, 2)
        XCTAssertEqual(metadata.relays?[0], relay1)
        XCTAssertEqual(metadata.relays?[1], relay2)
    }

    func testNaddrExcludeAuthor() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let naddr = try XCTUnwrap(event.naddr(includeAuthor: false))
        XCTAssertEqual(naddr, "naddr1qqqqxpqqqqn3qat5qqg")

        let metadata = try XCTUnwrap(decodedMetadata(from: naddr))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertNil(metadata.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays, [])
    }

    func testShareableEventCoordinatesExcludeAuthor() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates(includeAuthor: false))
        XCTAssertEqual(shareableEventCoordinates, "naddr1qqqqxpqqqqn3qat5qqg")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertNil(metadata.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays, [])
    }

    func testNaddrExcludeKind() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let naddr = try XCTUnwrap(event.naddr(includeKind: false))
        XCTAssertEqual(naddr, "naddr1qqqqygyeglukt8wcpsmgysptvyh4g3lzsfyejlanwz2spse2tp0tp9mngq8y2x7g")

        let metadata = try XCTUnwrap(decodedMetadata(from: naddr))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertNil(metadata.kind)
        XCTAssertEqual(metadata.relays, [])
    }

    func testShareableEventCoordinatesExcludeKind() throws {
        let event: MuteListEvent = try decodeFixture(filename: "mute_list")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates(includeKind: false))
        XCTAssertEqual(shareableEventCoordinates, "naddr1qqqqygyeglukt8wcpsmgysptvyh4g3lzsfyejlanwz2spse2tp0tp9mngq8y2x7g")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, "")
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertNil(metadata.kind)
        XCTAssertEqual(metadata.relays, [])
    }

}
