//
//  DateComponentsAdditionsTests.swift
//
//
//  Created by Terry Yiu on 11/16/23.
//

import XCTest
@testable import NostrSDK

final class DateComponentsAdditionsTests: XCTestCase {

    func testDateComponentsInitDateString() throws {
        XCTAssertNil(DateComponents(dateString: "notavaliddate"))
        XCTAssertNil(DateComponents(dateString: "2023-1-1"))
        XCTAssertNil(DateComponents(dateString: "23-11-16"))
        XCTAssertNil(DateComponents(dateString: "20231116"))
        XCTAssertNil(DateComponents(dateString: "2023-02-31"))

        let dateComponents2 = try XCTUnwrap(DateComponents(dateString: "2023-11-16"))
        XCTAssertEqual(dateComponents2, DateComponents(calendar: Calendar(identifier: .iso8601), year: 2023, month: 11, day: 16))
    }

}
