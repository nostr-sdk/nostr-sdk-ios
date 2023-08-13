//
//  ReactionEvent.swift
//  
//
//  Created by Terry Yiu on 8/12/23.
//

import Foundation

/// A reaction event (kind 7) in response to a different event.
///
/// See [NIP-25](https://github.com/nostr-protocol/nips/blob/master/25.md).
public class ReactionEvent: NostrEvent {
    public var reactedEventId: String? {
        tags.last(where: { $0.name == .event })?.value
    }

    public var reactedEventPubkey: String? {
        tags.last(where: { $0.name == .pubkey })?.value
    }
}
