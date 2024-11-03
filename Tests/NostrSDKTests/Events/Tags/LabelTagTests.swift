//
//  LabelTagTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

@testable import NostrSDK
import XCTest

final class LabelTagTests: XCTestCase, EventVerifying {

    func testLabels() throws {
        let event = try TextNoteEvent.Builder()
            .appendLabels("IT-MI", "US-CA", namespace: "ISO-3166-2")
            .appendLabels("en", namespace: "ISO-639-1")
            .appendLabels("Milan", "San Francisco", mark: "cities")
            .appendLabels("Italy", "United States of America")
            .content("It's beautiful here in Milan and wonderful there in San Francisco!")
            .build(signedBy: .test)

        XCTAssertEqual(event.labels(for: "ISO-3166-2"), ["IT-MI", "US-CA"])
        XCTAssertEqual(event.labels(for: "ISO-639-1"), ["en"])
        XCTAssertEqual(event.labels(for: "cities"), ["Milan", "San Francisco"])
        XCTAssertEqual(event.labels(for: nil), ["Italy", "United States of America"])
        XCTAssertEqual(event.labels(for: "ugc"), ["Italy", "United States of America"])
        XCTAssertEqual(event.labels(for: "doesnotexist"), [])

        XCTAssertEqual(event.labelNamespaces, ["ISO-3166-2", "ISO-639-1"])

        let labels = event.labels
        XCTAssertEqual(labels["ISO-3166-2"], ["IT-MI", "US-CA"])
        XCTAssertEqual(labels["ISO-639-1"], ["en"])
        XCTAssertEqual(labels["cities"], ["Milan", "San Francisco"])
        XCTAssertEqual(labels["ugc"], ["Italy", "United States of America"])
        XCTAssertEqual(labels["doesnotexist"], nil)

        try verifyEvent(event)
    }

}
