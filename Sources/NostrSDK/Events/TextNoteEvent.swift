//
//  TextNoteEvent.swift
//  
//
//  Created by Bryan Montz on 7/23/23.
//

import Foundation

/// An event that contains plaintext content.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/b503f8a92b22be3037b8115fe3e644865a4fa155/01.md#basic-event-kinds)
public final class TextNoteEvent: NostrEvent {
    
    /// Pubkeys mentioned in the note content.
    public var mentionedPubkeys: [String] {
        let pubkeyTags = tags.filter { $0.identifier == .pubkey }
        return pubkeyTags.map { $0.contentIdentifier }
    }
    
    /// Events mentioned in the note content.
    public var mentionedEventIds: [String] {
        let eventTags = tags.filter { $0.identifier == .event }
        return eventTags.map { $0.contentIdentifier }
    }
}
