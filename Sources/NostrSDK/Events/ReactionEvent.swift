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

public extension EventCreating {
    
    /// Creates a ``ReactionEvent`` (kind 7) in response to a different ``NostrEvent`` and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the reaction.
    ///   - reactedEvent: The NostrEvent being reacted to.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReactionEvent``.
    ///
    /// See [NIP-25 - Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
    func reaction(withContent content: String, reactedEvent: NostrEvent, signedBy keypair: Keypair) throws -> ReactionEvent {
        let eventTag = Tag.event(reactedEvent.id)
        let pubkeyTag = Tag.pubkey(reactedEvent.pubkey)
        
        var tags = reactedEvent.tags.filter { $0.name == TagName.event.rawValue || $0.name == TagName.pubkey.rawValue }
        tags.append(eventTag)
        tags.append(pubkeyTag)
        
        return try ReactionEvent(content: content, tags: tags, signedBy: keypair)
    }

    /// Creates a ``ReactionEvent`` (kind 7) in response to a different ``NostrEvent`` and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - customEmoji: The custom emoji to emojify with if the matching shortcode is found in the content field.
    ///   - reactedEvent: The NostrEvent being reacted to.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReactionEvent``.
    ///
    /// See [NIP-25 - Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
    func reaction(withCustomEmoji customEmoji: CustomEmoji, reactedEvent: NostrEvent, signedBy keypair: Keypair) throws -> ReactionEvent {
        let eventTag = Tag.event(reactedEvent.id)
        let pubkeyTag = Tag.pubkey(reactedEvent.pubkey)

        var tags = reactedEvent.tags.filter { $0.name == TagName.event.rawValue || $0.name == TagName.pubkey.rawValue }
        tags.append(eventTag)
        tags.append(pubkeyTag)
        tags.append(customEmoji.tag)

        return try ReactionEvent(content: ":\(customEmoji.shortcode):", tags: tags, signedBy: keypair)
    }
}
