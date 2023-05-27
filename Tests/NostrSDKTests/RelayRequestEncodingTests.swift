//
//  RelayRequestEncodingTests.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

@testable import NostrSDK
import XCTest

final class RelayRequestEncodingTests: XCTestCase, FixtureLoading {

    func testEncodeClose() throws {
        guard let request = RelayRequest.close(subscriptionId: "some-subscription-id") else {
            XCTFail("failed to encode request")
            return
        }

        let expected = try loadFixtureString("close_request")

        XCTAssertEqual(request, expected)
    }

    func testEncodeEvent() throws {
        let eventTag = EventTag(identifier: .event, contentIdentifier: "93930d65435d49db723499335473920795e7f13c45600dcfad922135cf44bd63")
        let pubkeyTag = EventTag(identifier: .pubkey, contentIdentifier: "f8e6c64342f1e052480630e27e1016dce35fc3a614e60434fef4aa2503328ca9")
        let event = NostrEvent(id: "fa5ed84fc8eeb959fd39ad8e48388cfc33075991ef8e50064cfcecfd918bb91b",
                               pubkey: "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2",
                               createdAt: 1682080184,
                               kind: .textNote,
                               tags: [eventTag, pubkeyTag],
                               content: "I think it stays persistent on your profile, but interface setting doesn’t persist. Bug.  ",
                               signature: "96e6667348b2b1fc5f6e73e68fb1605f571ad044077dda62a35c15eb8290f2c4559935db461f8466df3dcf39bc2e11984c5344f65aabee4520dd6653d74cdc09")
        guard let request = RelayRequest.event(event) else {
            XCTFail("failed to encode request")
            return
        }

        let expected = try loadFixtureString("event_request")

        XCTAssertTrue(areEqualJSONArrayStrings(request, expected))
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

        guard let request = RelayRequest.count(subscriptionId: "some-subscription-id", filter: filter) else {
            XCTFail("failed to encode request")
            return
        }

        let expected = try loadFixtureString("count_request")

        XCTAssertTrue(areEqualJSONArrayStrings(request, expected))
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

        guard let request = RelayRequest.request(subscriptionId: "some-subscription-id", filter: filter) else {
            XCTFail("failed to encode request")
            return
        }

        let expected = try loadFixtureString("req")

        XCTAssertTrue(areEqualJSONArrayStrings(request, expected))
    }
}
