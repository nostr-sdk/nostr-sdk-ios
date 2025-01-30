//
//  ContentWarningTagTests.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

@testable import NostrSDK
import XCTest

final class ContentWarningTagTests: XCTestCase, EventVerifying {

    func testContentWarning() throws {
        let event = try NostrEvent.Builder(kind: .textNote)
            .contentWarning("Trigger warning.")
            .content("Pineapple goes great on pizza.")
            .build(signedBy: .test)

        XCTAssertEqual(event.contentWarning, "Trigger warning.")

        XCTAssertEqual(event.tags.count, 1)
        let tag = try XCTUnwrap(event.tags.first)
        XCTAssertEqual(tag.name, "content-warning")
        XCTAssertEqual(tag.value, "Trigger warning.")

        try verifyEvent(event)
    }

}
