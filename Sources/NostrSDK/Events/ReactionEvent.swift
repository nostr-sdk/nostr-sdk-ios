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
    @available(*, deprecated, message: "Deprecated in favor of ReactionEvent.Builder.")
    func reaction(withContent content: String, reactedEvent: NostrEvent, signedBy keypair: Keypair) throws -> ReactionEvent {
        try ReactionEvent.Builder()
            .reactedEvent(reactedEvent)
            .content(content)
            .build(signedBy: keypair)
    }

    /// Creates a ``ReactionEvent`` (kind 7) in response to a different ``NostrEvent`` and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - customEmoji: The custom emoji to react to `reactedEvent` with.
    ///   - reactedEvent: The NostrEvent being reacted to.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReactionEvent``.
    ///
    /// See [NIP-25 - Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
    @available(*, deprecated, message: "Deprecated in favor of ReactionEvent.Builder.")
    func reaction(withCustomEmoji customEmoji: CustomEmoji, reactedEvent: NostrEvent, signedBy keypair: Keypair) throws -> ReactionEvent {
        try ReactionEvent.Builder()
            .reactedEvent(reactedEvent)
            .customEmoji(customEmoji)
            .build(signedBy: keypair)
    }
}

public extension ReactionEvent {
    /// Builder of a ``ReactionEvent``.
    final class Builder: NostrEvent.Builder<ReactionEvent> {
        public init() {
            super.init(kind: .reaction)
        }

        /// Sets the ``NostrEvent`` that is being reacted to from this reaction event that is being built.
        @discardableResult
        public final func reactedEvent(_ reactedEvent: NostrEvent, relayURL: URL? = nil) throws -> Self {
            let eventTag: Tag
            let pubkeyTag: Tag

            if let relayURL {
                eventTag = Tag.event(reactedEvent.id, otherParameters: [relayURL.absoluteString])
                pubkeyTag = Tag.pubkey(reactedEvent.pubkey, otherParameters: [relayURL.absoluteString])
            } else {
                eventTag = Tag.event(reactedEvent.id)
                pubkeyTag = Tag.pubkey(reactedEvent.pubkey)
            }

            appendTags(contentsOf: reactedEvent.tags.filter { $0.name == TagName.event.rawValue || ($0.name == TagName.pubkey.rawValue && $0 != pubkeyTag) })
            appendTags(eventTag)
            appendTags(pubkeyTag)
            appendTags(Tag.kind(reactedEvent.kind))

            return self
        }

        /// Sets the custom emoji to react to `reactedEvent` with.
        @discardableResult
        public final func customEmoji(_ customEmoji: CustomEmoji) throws -> Self {
            appendTags(customEmoji.tag)
            content(":\(customEmoji.shortcode):")
            return self
        }
    }
}
