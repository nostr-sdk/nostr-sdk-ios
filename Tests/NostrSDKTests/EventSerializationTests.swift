//
//  EventSerializationTests.swift
//
//
//  Created by Bryan Montz on 6/15/23.
//

import Foundation
@testable import NostrSDK
import XCTest

final class EventSerializationTests: XCTestCase, FixtureLoading {
    
    func testEventSerialization() throws {
        let event: NostrEvent = try decodeFixture(filename: "simple_note")
        let idData = try XCTUnwrap(event.id.hexadecimalData)
        let calculatedId = event.calculatedId.hexadecimalData
        XCTAssertEqual(idData, calculatedId)
    }
    
    func testEventSerializationWithTags() throws {
        let event: NostrEvent = try decodeFixture(filename: "text_note")
        let idData = try XCTUnwrap(event.id.hexadecimalData)
        let calculatedId = event.calculatedId.hexadecimalData
        XCTAssertEqual(idData, calculatedId)
    }
}
