//
//  HideChannelMessageEvent.swift
//
//
//  Created by Konstantin Yurchenko, Jr on 9/11/24.
//

import Foundation

/// User no longer wants to see a certain message.
/// See [NIP-28](https://github.com/nostr-protocol/nips/blob/master/28.md#kind-43-hide-message).
public class HideChannelMessageEvent: NostrEvent {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    init(content: String, tags: [Tag], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: Self.kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    class var kind: EventKind {
        .channelHideMessage
    }
}

public extension EventCreating {
    func hideChannelMessageEvent(withContent content: String, signedBy keypair: Keypair) throws -> HideChannelMessageEvent {
        return try HideChannelMessageEvent(content: content, tags: [], signedBy: keypair)
    }
}
