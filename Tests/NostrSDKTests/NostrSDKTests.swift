import XCTest
@testable import NostrSDK

final class NostrSDKTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NostrSDK().text, "Hello, World!")
    }
}
