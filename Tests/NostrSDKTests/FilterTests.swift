//
//  FilterTests.swift
//
//
//  Created by Joel Klabo on 5/26/23.
//

import NostrSDK
import XCTest

final class FilterTests: XCTestCase, FixtureLoading, JSONTesting {

    func testFilterEncoding() throws {
        let filter = Filter(authors: ["d9fa34214aa9d151c4f4db843e9c2af4f246bab4205137731f91bcfa44d66a62"],
                            kinds: [3],
                            limit: 1)

        let expected = try loadFixtureString("filter")

        let encoder = JSONEncoder()
        let result = try encoder.encode(filter)
        let resultString = try XCTUnwrap(String(data: result, encoding: .utf8))

        XCTAssertTrue(areEquivalentJSONObjectStrings(expected, resultString))
    }
    
    func testFilterWithAllFieldsEncoding() throws {
        let filter = Filter(ids: ["pubkey1"],
                            authors: ["author1", "author2"],
                            kinds: [1, 2, 3],
                            events: ["event1", "event2"],
                            pubkeys: ["referencedPubkey1"],
                            tags: ["t": ["hashtag"], "e": ["thisEventFilterIsDiscarded"], "p": ["thisPubkeyFilterIsDiscarded"]],
                            since: 1234,
                            until: 12345,
                            limit: 5)

        let expected = try loadFixtureString("filter_all_fields")

        let encoder = JSONEncoder()
        let result = try encoder.encode(filter)
        let resultString = try XCTUnwrap(String(data: result, encoding: .utf8))

        XCTAssertTrue(areEquivalentJSONObjectStrings(expected, resultString))
    }

    func testFilterWithInvalidTagsEncoding() throws {
        XCTAssertNil(Filter(tags: ["*": []]))
    }

    func testFilterDecoding() throws {
        let expectedFilter = Filter(ids: ["pubkey1"],
                                    authors: ["author1", "author2"],
                                    kinds: [1, 2, 3],
                                    events: ["event1", "event2"],
                                    pubkeys: ["referencedPubkey1"],
                                    tags: ["t": ["hashtag"]],
                                    since: 1234,
                                    until: 12345,
                                    limit: 5)
        let filter: Filter = try decodeFixture(filename: "filter_all_fields")
        XCTAssertEqual(expectedFilter, filter)
    }

    func testFilterWithExtraFieldsDecoding() throws {
        let expectedFilter = Filter(ids: ["pubkey1"],
                                    authors: ["author1", "author2"],
                                    kinds: [1, 2, 3],
                                    events: ["event1", "event2"],
                                    pubkeys: ["referencedPubkey1"],
                                    tags: ["t": ["hashtag"]],
                                    since: 1234,
                                    until: 12345,
                                    limit: 5)
        let filter: Filter = try decodeFixture(filename: "filter_with_extra_fields")
        XCTAssertEqual(expectedFilter, filter)
    }
}
