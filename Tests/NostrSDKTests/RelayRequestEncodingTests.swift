//
//  RelayRequestEncodingTests.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

@testable import NostrSDK
import XCTest

final class RelayRequestEncodingTests: XCTestCase, FixtureLoading, JSONTesting {

    func testEncodeEvent() throws {
        let eventTag = Tag.event("93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63")
        let pubkeyTag = Tag.pubkey("f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9")
        let event = NostrEvent(id: "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b",
                               pubkey: "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2",
                               createdAt: 1682080184,
                               kind: .textNote,
                               tags: [eventTag, pubkeyTag],
                               content: "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ",
                               signature: "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")

        let request = try XCTUnwrap(RelayRequest.event(event), "failed to encode request")
        let expected = try loadFixtureString("event_request")

        XCTAssertTrue(areEquivalentJSONArrayStrings(request.encoded, expected))
    }

    func testEncodeReq() throws {
        let filter = Filter(ids: nil,
                            authors: ["some-pubkey"],
                            kinds: [1, 7],
                            events: nil,
                            pubkeys: nil,
                            since: nil,
                            until: nil,
                            limit: nil)

        let request = try XCTUnwrap(RelayRequest.request(subscriptionId: "some-subscription-id", filter: filter), "failed to encode request")
        let expected = try loadFixtureString("req")

        XCTAssertTrue(areEquivalentJSONArrayStrings(request.encoded, expected))
    }

    func testEncodeClose() throws {
        let request = try XCTUnwrap(RelayRequest.close(subscriptionId: "some-subscription-id"), "failed to encode request")
        let expected = try loadFixtureString("close_request")

        XCTAssertEqual(request.encoded, expected)
    }

    func testEncodeCount() throws {
        let filter = Filter(ids: nil,
                            authors: ["some-pubkey"],
                            kinds: [1, 7],
                            events: nil,
                            pubkeys: nil,
                            since: nil,
                            until: nil,
                            limit: nil)

        let request = try XCTUnwrap(RelayRequest.count(subscriptionId: "some-subscription-id", filter: filter), "failed to encode request")
        let expected = try loadFixtureString("count_request")

        XCTAssertTrue(areEquivalentJSONArrayStrings(request.encoded, expected))
    }
}
