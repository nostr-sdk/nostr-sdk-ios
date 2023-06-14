//
//  NIP05ValidationTests.swift
//
//
//  Created by Bryan Montz on 6/12/23.
//

import NostrSDK
import XCTest

final class MockRequester: DataRequesting {
    
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        let json: String
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        switch components.host {
        case "test.com":
            json = """
            {
              "names": {
                "bob": "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9"
              },
              "relays": {
                "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9": [ "wss://relay.example.com", "wss://relay2.example.com" ]
              }
            }
            """
        default:
            json = ""
        }
        
        return (json.data(using: .utf8)!, URLResponse())
    }
}

final class NIP05ValidationTests: XCTestCase, NIP05Validating {
    
    func testInvalidIdentifier() async throws {
        do {
            try await validateNIP05Identifier("abst3341", pubkey: "test-pubkey")
            XCTFail("expected to throw error")
        } catch let error as NIP05ValidationError {
            XCTAssertEqual(error, NIP05ValidationError.invalidIdentifierFormat)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
    
    func testInvalidIdentifier2() async throws {
        do {
            try await validateNIP05Identifier("user@test", pubkey: "test-pubkey")
            XCTFail("expected to throw error")
        } catch let error as NIP05ValidationError {
            XCTAssertEqual(error, NIP05ValidationError.invalidIdentifierFormat)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
    
    func testInvalidURL() async throws {
        do {
            try await validateNIP05Identifier("user@test\\.biz", pubkey: "test-pubkey")
            XCTFail("expected to throw error")
        } catch let error as NIP05ValidationError {
            XCTAssertEqual(error, NIP05ValidationError.invalidComposedURL)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
    
    func testNothingAtURL() async throws {
        do {
            try await validateNIP05Identifier("user@test.biz",
                                              pubkey: "test-pubkey",
                                              dataRequester: MockRequester())
            XCTFail("expected to throw error")
        } catch let error as DecodingError {
            if case .dataCorrupted = error {
                // pass
            } else {
                XCTFail("unexpected error: \(error)")
            }
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
    
    func testSuccessfulValidation() async throws {
        do {
            try await validateNIP05Identifier("bob@test.com",
                                              pubkey: "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9",
                                              dataRequester: MockRequester())
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
    
    func testRequestingRelays() async throws {
        let relays = try await relayURLsForNIP05Identifier("bob@test.com", dataRequester: MockRequester())
        let expectedRelays = [
            "wss://relay.example.com",
            "wss://relay2.example.com"
        ]
        XCTAssertEqual(relays, expectedRelays)
    }
}
