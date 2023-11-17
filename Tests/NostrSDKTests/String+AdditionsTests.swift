//
//  String+AdditionsTests.swift
//
//
//  Created by Terry Yiu on 11/16/23.
//

import XCTest
@testable import NostrSDK

final class StringAdditionsTests: XCTestCase {

    func testDateStringAsDateComponents() throws {
        XCTAssertNil("notavaliddate".dateStringAsDateComponents)
        XCTAssertNil("2023-1-1".dateStringAsDateComponents)
        XCTAssertNil("23-11-16".dateStringAsDateComponents)
        XCTAssertNil("20231116".dateStringAsDateComponents)
        XCTAssertNil("2023-02-31".dateStringAsDateComponents)

        let dateComponents2 = try XCTUnwrap("2023-11-16".dateStringAsDateComponents)
        XCTAssertEqual(dateComponents2, DateComponents(calendar: Calendar(identifier: .iso8601), year: 2023, month: 11, day: 16))
    }

}
