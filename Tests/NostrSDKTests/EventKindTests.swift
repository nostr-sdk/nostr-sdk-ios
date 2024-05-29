//
//  EventKindTests.swift
//  
//
//  Created by Terry Yiu on 12/23/23.
//

import XCTest
@testable import NostrSDK

final class EventKindTests: XCTestCase {

    func testHasClassForKind() {
        EventKind.allCases.forEach { kind in
            XCTAssertTrue(kind.classForKind !== NostrEvent.self, "NostrEvent subclass for known event kind \"\(kind)\" was not defined.")
        }
    }

    func testIsNonParameterizedReplaceable() throws {
        XCTAssertTrue(EventKind.metadata.isNonParameterizedReplaceable)
        XCTAssertTrue(EventKind.followList.isNonParameterizedReplaceable)
        XCTAssertTrue(EventKind.muteList.isNonParameterizedReplaceable)
        XCTAssertTrue(EventKind(rawValue: 19999).isNonParameterizedReplaceable)

        XCTAssertFalse(EventKind.textNote.isNonParameterizedReplaceable)
        XCTAssertFalse(EventKind(rawValue: 999).isNonParameterizedReplaceable)
        XCTAssertFalse(EventKind(rawValue: 20000).isNonParameterizedReplaceable)
    }

    func testIsParameterizedReplaceable() throws {
        XCTAssertTrue(EventKind(rawValue: 30000).isParameterizedReplaceable)
        XCTAssertTrue(EventKind(rawValue: 39999).isParameterizedReplaceable)

        XCTAssertFalse(EventKind(rawValue: 29999).isParameterizedReplaceable)
        XCTAssertFalse(EventKind(rawValue: 40000).isParameterizedReplaceable)
    }

}
