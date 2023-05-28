//
//  JSONEqualityTests.swift
//  
//
//  Created by Joel Klabo on 5/27/23.
//

import XCTest

final class JSONEqualityTests: XCTestCase, JSONTesting {

    func testJSONArrayEquality() {
        // Test with identical arrays
        XCTAssertTrue(areEquivalentJSONArrayStrings("[1, 2, 3]", "[1, 2, 3]"))

        // Test with identical arrays in different order
        XCTAssertTrue(areEquivalentJSONArrayStrings("[1, 2, 3]", "[3, 2, 1]"))

        // Test with different arrays
        XCTAssertFalse(areEquivalentJSONArrayStrings("[1, 2, 3]", "[4, 5, 6]"))

        // Test with nil values
        XCTAssertTrue(areEquivalentJSONArrayStrings(nil, nil))
        XCTAssertFalse(areEquivalentJSONArrayStrings(nil, "[1, 2, 3]"))
        XCTAssertFalse(areEquivalentJSONArrayStrings("[1, 2, 3]", nil))
    }

    func testJSONObjectEquality() {
        // Test with identical objects
        XCTAssertTrue(areEquivalentJSONObjectStrings("{\"key1\": \"value1\", \"key2\": \"value2\"}", "{\"key1\": \"value1\", \"key2\": \"value2\"}"))

        // Test with identical objects with keys in different order
        XCTAssertTrue(areEquivalentJSONObjectStrings("{\"key1\": \"value1\", \"key2\": \"value2\"}", "{\"key2\": \"value2\", \"key1\": \"value1\"}"))

        // Test with different objects
        XCTAssertFalse(areEquivalentJSONObjectStrings("{\"key1\": \"value1\", \"key2\": \"value2\"}", "{\"key3\": \"value3\", \"key4\": \"value4\"}"))

        // Test with nil values
        XCTAssertTrue(areEquivalentJSONObjectStrings(nil, nil))
        XCTAssertFalse(areEquivalentJSONObjectStrings(nil, "{\"key1\": \"value1\", \"key2\": \"value2\"}"))
        XCTAssertFalse(areEquivalentJSONObjectStrings("{\"key1\": \"value1\", \"key2\": \"value2\"}", nil))
    }

}
