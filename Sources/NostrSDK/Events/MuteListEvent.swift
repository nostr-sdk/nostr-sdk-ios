//
//  MuteListEvent.swift
//
//
//  Created by Bryan Montz on 12/15/23.
//

import Foundation

/// An event that contains various things the user doesn't want to see in their feeds.
/// 
/// See [NIP-51](https://github.com/nostr-protocol/nips/blob/master/51.md#standard-lists).
public final class MuteListEvent: NostrEvent, HashtagInterpreting, PrivateTagInterpreting, NonParameterizedReplaceableEvent {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .muteList, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// The publicly muted public keys (authors).
    public var pubkeys: [String] {
        allValues(forTagName: .pubkey)
    }
    
    /// The publicly muted event ids (threads).
    public var eventIds: [String] {
        allValues(forTagName: .event)
    }
    
    /// The publicly muted keywords.
    public var keywords: [String] {
        allValues(forTagName: .word)
    }
    
    /// The privately muted public keys (authors).
    public func privatePubkeys(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .pubkey, using: keypair)
    }
    
    /// The privately muted event ids (threads).
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The event ids.
    public func privateEventIds(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .event, using: keypair)
    }
    
    /// The privately muted hashtags.
    public func privateHashtags(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .hashtag, using: keypair)
    }
    
    /// The privately muted keywords.
    public func privateKeywords(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .word, using: keypair)
    }
}
