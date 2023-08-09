//
//  TextNoteRepostEvent.swift
//  
//
//  Created by Bryan Montz on 8/3/23.
//

import Foundation

/// A repost is a kind 6 event that is used to signal to followers that a kind 1 text note is worth reading.
///
/// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#reposts).
public final class TextNoteRepostEvent: GenericRepostEvent {
    
    /// The note that is being reposted.
    var repostedNote: TextNoteEvent? {
        guard let jsonData = content.data(using: .utf8),
              let note: TextNoteEvent = try? JSONDecoder().decode(TextNoteEvent.self, from: jsonData) else {
            return nil
        }
        return note
    }
}
