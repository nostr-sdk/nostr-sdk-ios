//
//  AlternativeSummaryTagTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

@testable import NostrSDK
import XCTest

final class AlternativeSummaryTagTests: XCTestCase, FixtureLoading {

    func testAlternativeSummary() throws {
        let alternativeSummary = "Alternative summary to display for clients that do not support this event kind."
        let customEvent = try NostrEvent.Builder(kind: EventKind(rawValue: 23456))
            .alternativeSummary(alternativeSummary)
            .build(signedBy: .test)
        XCTAssertEqual(customEvent.alternativeSummary, alternativeSummary)

        let decodedCustomEventWithAltTag: NostrEvent = try decodeFixture(filename: "custom_event_alt_tag")
        XCTAssertEqual(decodedCustomEventWithAltTag.alternativeSummary, alternativeSummary)
    }

}
