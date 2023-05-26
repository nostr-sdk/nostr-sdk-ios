//
//  FilterEncodingTests.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

@testable import NostrSDK
import XCTest

final class FilterEncodingTests: XCTestCase, FixtureLoading {

    func testFilterEncoding() throws {
        let filter = Filter(ids: nil,
                            authors: ["d9fa34214aa9d151c4f4db843e9c2af4f246bab4205137731f91bcfa44d66a62"],
                            kinds: [3],
                            events: nil,
                            pubkeys: nil,
                            since: nil,
                            until: nil,
                            limit: 1)

        let expected = try loadFixtureString("filter")

        let encoder = JSONEncoder()
        let result = try encoder.encode(filter)
        let resultString = String(decoding: result, as: UTF8.self)

        XCTAssertTrue(areEqualJSONObjectStrings(expected, resultString))
    }

}
