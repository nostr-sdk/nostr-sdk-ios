//
//  EventCreatingTests.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation
import NostrSDK
import XCTest

final class EventCreatingTests: XCTestCase, EventCreating, EventVerifying {
    
    func testCreateSignedTextNote() throws {
        let note = try textNote(withContent: "Hello world!",
                                signedBy: Keypair.test)
        
        XCTAssertEqual(note.kind, .textNote)
        XCTAssertEqual(note.content, "Hello world!")
        XCTAssertEqual(note.pubkey, Keypair.test.publicKey.hex)
        XCTAssertEqual(note.tags, [])
        
        try verifyEvent(note)
    }
}
