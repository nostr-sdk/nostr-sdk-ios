//
//  CreateChannelMessageEvent.swift
//
//
//  Created by Konstantin Yurchenko, Jr on 9/11/24.
//

import Foundation

/// Send a text message to a channel.
/// See [NIP-28](https://github.com/nostr-protocol/nips/blob/master/28.md#kind-42-create-channel-message).
public class CreateChannelMessageEvent: NostrEvent {
    
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
        .channelMessage
    }
}

public extension EventCreating {
    func createChannelMessageEvent(
        withContent content: String,
        eventId: String,
        hashtag: String? = nil,
        signedBy keypair: Keypair,
        otherParameters: [String]? = nil
    ) throws -> CreateChannelMessageEvent {
        
        var tags: [Tag] = [
            Tag.pubkey(keypair.publicKey.hex),
        ]
        
        if let otherParameters = otherParameters {
            tags.append(Tag.event(eventId, otherParameters: otherParameters))
        } else {
            tags.append(Tag.event(eventId))
        }
        
        if let hashtag = hashtag {
            tags.append(Tag.hashtag(hashtag))
        }

        return try CreateChannelMessageEvent(content: content, tags: tags, signedBy: keypair)
    }
}