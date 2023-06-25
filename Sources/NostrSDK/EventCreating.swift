//
//  EventCreating.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation

public protocol EventCreating {}
public extension EventCreating {
    
    /// Creates a text note event (kind 1) and signs it with the provided ``Keypair``
    /// - Parameters:
    ///   - content: The content of the text note
    ///   - keypair: The Keypair to sign with
    /// - Returns: The signed text note event
    func textNote(withContent content: String, signedBy keypair: Keypair) throws -> NostrEvent {
        try NostrEvent(kind: .textNote, content: content, signedBy: keypair)
    }
}
