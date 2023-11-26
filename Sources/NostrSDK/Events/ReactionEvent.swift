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
public class ReactionEvent: NostrEvent, CustomEmojiInterpreting {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .reaction, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    public var reactedEventId: String? {
        tags.last(where: { $0.name == TagName.event.rawValue })?.value
    }

    public var reactedEventPubkey: String? {
        tags.last(where: { $0.name == TagName.pubkey.rawValue })?.value
    }
}
