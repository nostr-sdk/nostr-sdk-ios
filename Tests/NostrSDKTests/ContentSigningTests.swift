//
//  ContentSigningTests.swift
//
//
//  Created by Bryan Montz on 6/20/23.
//

import Foundation
@testable import NostrSDK
import XCTest

final class ContentSigningTests: XCTestCase, FixtureLoading, ContentSigning, SignatureVerifying {
    
    func testSignEvent() throws {
        let event: NostrEvent = try decodeFixture(filename: "test_event")
        
        let calculatedId = event.calculatedId
        XCTAssertEqual(calculatedId, event.id)
        
        // sign a few times and verify the signatures
        for _ in 1...4 {
            let signature = try Keypair.test.privateKey.signatureForContent(calculatedId)
            try verifySignature(signature, for: calculatedId, withPublicKey: Keypair.test.publicKey.hex)
        }
    }
}
