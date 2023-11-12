//
//  CustomEmojiTests.swift
//  
//
//  Created by Terry Yiu on 11/12/23.
//

@testable import NostrSDK
import XCTest

final class CustomEmojiTests: XCTestCase, CustomEmojiValidating {
    func testInitSucceeds() throws {
        let shortcode = "ostrich"
        let imageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        let customEmoji = try XCTUnwrap(CustomEmoji(shortcode: shortcode, imageURL: imageURL))
        XCTAssertEqual(customEmoji.shortcode, shortcode)
        XCTAssertEqual(customEmoji.imageURL, imageURL)
        XCTAssertEqual(customEmoji.tag, Tag(name: .emoji, value: shortcode, otherParameters: [imageURL.absoluteString]))
    }

    func testInitFailsOnInvalidShortcode() throws {
        let imageURL = try XCTUnwrap(URL(string: "https://nostrsdk.com/ostrich.png"))
        XCTAssertNil(CustomEmoji(shortcode: ":ostrich:", imageURL: imageURL))
    }

    func testCustomEmojiValidating() throws {
        XCTAssertTrue(isValidShortcode("abcdefghijklmnoprstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ_0123456789"))
        XCTAssertFalse(isValidShortcode(":abcdefghijklmnoprstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ_0123456789:"))
    }
}
