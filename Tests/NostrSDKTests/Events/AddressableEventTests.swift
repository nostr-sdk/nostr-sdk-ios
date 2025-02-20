//
//  AddressableEventTests.swift
//
//
//  Created by Terry Yiu on 6/30/24.
//

@testable import NostrSDK
import XCTest

final class AddressableEventTests: XCTestCase, FixtureLoading, MetadataCoding {

    func testReplaceableEventCoordinates() throws {
        let event: LongformContentEvent = try decodeFixture(filename: "longform")
        let publicKey = try XCTUnwrap(PublicKey(hex: event.pubkey))
        let expectedReplaceableEventCoordinates = try XCTUnwrap(EventCoordinates(kind: .longformContent, pubkey: publicKey, identifier: event.identifier))
        XCTAssertEqual(event.replaceableEventCoordinates(relayURL: nil), expectedReplaceableEventCoordinates)
    }

    func testShareableEventCoordinates() throws {
        let event: LongformContentEvent = try decodeFixture(filename: "longform")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates())
        XCTAssertEqual(shareableEventCoordinates, "naddr1qq25vwznf9yj63e4f3z82m2ytfnhs36r2eg4xq3qwjyk3rq9hdepztwc9420m0exhd0s8cw7fr5hscwcln3ffgh3d9rqxpqqqp65wj0jelr")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, event.identifier)
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays, [])
    }

    func testShareableEventCoordinatesWithRelays() throws {
        let relay1 = "wss://relay1.com"
        let relay2 = "wss://relay2.com"

        let event: LongformContentEvent = try decodeFixture(filename: "longform")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates(relayURLStrings: [relay1, relay2]))
        XCTAssertEqual(shareableEventCoordinates, "naddr1qq25vwznf9yj63e4f3z82m2ytfnhs36r2eg4xqgswaehxw309aex2mrp0ycjucm0d5q3qamnwvaz7tmjv4kxz7fj9e3k7mgzyp6gj6yvqkahyyfdmqk4fldly6a47qlpmeywj7rpmr7w999z7955vqcyqqq823cgq7hnn")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, event.identifier)
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays?.count, 2)
        XCTAssertEqual(metadata.relays?[0], relay1)
        XCTAssertEqual(metadata.relays?[1], relay2)
    }

    func testShareableEventCoordinatesExcludeAuthor() throws {
        let event: LongformContentEvent = try decodeFixture(filename: "longform")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates(includeAuthor: false))
        XCTAssertEqual(shareableEventCoordinates, "naddr1qq25vwznf9yj63e4f3z82m2ytfnhs36r2eg4xqcyqqq823cn0tk0s")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, event.identifier)
        XCTAssertNil(metadata.pubkey)
        XCTAssertEqual(metadata.kind, UInt32(event.kind.rawValue))
        XCTAssertEqual(metadata.relays, [])
    }

    func testShareableEventCoordinatesExcludeKind() throws {
        let event: LongformContentEvent = try decodeFixture(filename: "longform")
        let shareableEventCoordinates = try XCTUnwrap(event.shareableEventCoordinates(includeKind: false))
        XCTAssertEqual(shareableEventCoordinates, "naddr1qq25vwznf9yj63e4f3z82m2ytfnhs36r2eg4xq3qwjyk3rq9hdepztwc9420m0exhd0s8cw7fr5hscwcln3ffgh3d9rqncjtcg")

        let metadata = try XCTUnwrap(decodedMetadata(from: shareableEventCoordinates))
        XCTAssertNil(metadata.eventId)
        XCTAssertEqual(metadata.identifier, event.identifier)
        XCTAssertEqual(metadata.pubkey, event.pubkey)
        XCTAssertNil(metadata.kind)
        XCTAssertEqual(metadata.relays, [])
    }

}
