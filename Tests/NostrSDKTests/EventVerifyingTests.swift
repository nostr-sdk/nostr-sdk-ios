//
//  EventVerifyingTests.swift
//  
//
//  Created by Bryan Montz on 6/18/23.
//

import Foundation
import NostrSDK
import XCTest

final class EventVerifyingTests: XCTestCase, SignatureVerifying {
    
    func testVerifyValidSignature() throws {
        let signature = "4b28e1f4a27e152efbd9d9ec677350e7a59ee87c5165161f058ce809ca63b67e840b85c2b45d0d547062649d826bdb1c22102481bc3d3dc123e9570fc19e2b0a"
        let message = "79dbf85121617ef657d9baa303b9887cd39c8ce22facb367092d3ceb3c2bf76d"
        let publicKey = "07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f"
        XCTAssertNoThrow(try verifySignature(signature, for: message, withPublicKey: publicKey))
    }
    
    func testVerifyUnexpectedSignatureLength() {
        let signature = "b640b85c2b45d0d547062649d826bdb1c22102481bc3d3dc123e9570fc19e2b0a"
        let message = "79dbf85121617ef657d9baa303b9887cd39c8ce22facb367092d3ceb3c2bf76d"
        let publicKey = "07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f"
        
        XCTAssertThrowsError(try verifySignature(signature, for: message, withPublicKey: publicKey)) { error in
            XCTAssertEqual(error as? SignatureVerifyingError, SignatureVerifyingError.unexpectedSignatureLength)
        }
    }
    
    func testVerifyUnexpectedPublicKeyLength() throws {
        let signature = "3b28e1f4a27e152efbd9d9ec677350e7a59ee87c5165161f058ce809ca63b67e840b85c2b45d0d547062649d826bdb1c22102481bc3d3dc123e9570fc19e2b0a"
        let message = "79dbf85121617ef657d9baa303b9887cd39c8ce22facb367092d3ceb3c2bf76d"
        let publicKey = "07ecf9838136fac0729c5a33df1192ce75e330c9f"
        
        XCTAssertThrowsError(try verifySignature(signature, for: message, withPublicKey: publicKey)) { error in
            XCTAssertEqual(error as? SignatureVerifyingError, SignatureVerifyingError.unexpectedPublicKeyLength)
        }
    }
    
    func testVerifyInvalidSignature() throws {
        let signature = "3b28e1f4a27e152efbd9d9ec677350e7a59ee87c5165161f058ce809ca63b67e840b85c2b45d0d547062649d826bdb1c22102481bc3d3dc123e9570fc19e2b0a"
        let message = "79dbf85121617ef657d9baa303b9887cd39c8ce22facb367092d3ceb3c2bf76d"
        let publicKey = "07ecf9838136fe430fac43fa0860dbc62a0aac0729c5a33df1192ce75e330c9f"
        
        XCTAssertThrowsError(try verifySignature(signature, for: message, withPublicKey: publicKey)) { error in
            XCTAssertEqual(error as? SignatureVerifyingError, SignatureVerifyingError.invalidSignature)
        }
    }
}
