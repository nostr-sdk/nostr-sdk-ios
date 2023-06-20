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
        let privateKey = try XCTUnwrap(PrivateKey(nsec: "nsec163p74rxf58ndvav7ck8axx39qmt6dvwjgm8z98ckanenzf3mpjyq6875fz"))
        let publicKey = try XCTUnwrap(PublicKey(npub: "npub1n9rljevamqxrdqjq9dsj74z8u2pynxtlkdcf2qxr9fv9avyhwdqqf6w3at"))
        
        let event: NostrEvent = try decodeFixture(filename: "test_event")
        
        let calculatedId = event.serializedForSigning.data(using: .utf8)!.sha256.hexString
        XCTAssertEqual(calculatedId, event.id)
        
        // sign a few times and verify the signatures
        for _ in 1...4 {
            let signature = try privateKey.signatureForContent(calculatedId)
            try verifySignature(signature, for: calculatedId, with: publicKey.hex)
        }
    }
}
