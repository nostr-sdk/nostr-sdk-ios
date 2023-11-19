//
//  TimeOmittedDateTests.swift
//
//
//  Created by Terry Yiu on 11/16/23.
//

import XCTest
@testable import NostrSDK

final class TimeOmittedDateTests: XCTestCase {

    func testInitWithYearMonthDay() throws {
        XCTAssertNil(TimeOmittedDate(year: 2023, month: 2, day: 31))

        let timeOmittedDate = try XCTUnwrap(TimeOmittedDate(year: 2023, month: 11, day: 16))
        XCTAssertEqual(timeOmittedDate.year, 2023)
        XCTAssertEqual(timeOmittedDate.month, 11)
        XCTAssertEqual(timeOmittedDate.day, 16)
        XCTAssertEqual(timeOmittedDate.dateString, "2023-11-16")
    }

    func testInitWithDateString() throws {
        XCTAssertNil(TimeOmittedDate(dateString: "notavaliddate"))
        XCTAssertNil(TimeOmittedDate(dateString: "2023-1-1"))
        XCTAssertNil(TimeOmittedDate(dateString: "23-11-16"))
        XCTAssertNil(TimeOmittedDate(dateString: "20231116"))
        XCTAssertNil(TimeOmittedDate(dateString: "2023-02-31"))

        let timeOmittedDate = try XCTUnwrap(TimeOmittedDate(dateString: "2023-11-16"))
        XCTAssertEqual(timeOmittedDate.year, 2023)
        XCTAssertEqual(timeOmittedDate.month, 11)
        XCTAssertEqual(timeOmittedDate.day, 16)
        XCTAssertEqual(timeOmittedDate.dateString, "2023-11-16")
    }

}
