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

public extension EventCreating {
    
    /// Creates a ``MuteListEvent`` (kind 10000) containing things the user doesn't want to see in their feeds. Mute list items be publicly visible or private.
    /// - Parameters:
    ///   - publiclyMutedPubkeys: Pubkeys to mute.
    ///   - privatelyMutedPubkeys: Pubkeys to privately mute.
    ///   - publiclyMutedEventIds: Event ids to mute.
    ///   - privatelyMutedEventIds: Event ids to privately mute.
    ///   - publiclyMutedHashtags: Hashtags to mute.
    ///   - privatelyMutedHashtags: Hashtags to privately mute.
    ///   - publiclyMutedKeywords: Keywords to mute.
    ///   - privatelyMutedKeywords: Keywords to privately mute.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``MuteListEvent``.
    func muteList(withPubliclyMutedPubkeys publiclyMutedPubkeys: [String] = [],
                  privatelyMutedPubkeys: [String] = [],
                  publiclyMutedEventIds: [String] = [],
                  privatelyMutedEventIds: [String] = [],
                  publiclyMutedHashtags: [String] = [],
                  privatelyMutedHashtags: [String] = [],
                  publiclyMutedKeywords: [String] = [],
                  privatelyMutedKeywords: [String] = [],
                  signedBy keypair: Keypair) throws -> MuteListEvent {
        let publicTags: [Tag] = publiclyMutedPubkeys.map { .pubkey($0) } +
        publiclyMutedEventIds.map { .event($0) } +
        publiclyMutedHashtags.map { .hashtag($0) } +
        publiclyMutedKeywords.map { Tag(name: .word, value: $0) }
        
        let privateTags: [Tag] = privatelyMutedPubkeys.map { .pubkey($0) } +
        privatelyMutedEventIds.map { .event($0) } +
        privatelyMutedHashtags.map { .hashtag($0) } +
        privatelyMutedKeywords.map { Tag(name: .word, value: $0) }
        
        var encryptedContent: String?
        if !privateTags.isEmpty {
            let rawPrivateTags = privateTags.map { $0.raw }
            if let unencryptedData = try? JSONSerialization.data(withJSONObject: rawPrivateTags),
               let unencryptedContent = String(data: unencryptedData, encoding: .utf8) {
                encryptedContent = try nip04Encrypt(content: unencryptedContent,
                                                    privateKey: keypair.privateKey,
                                                    publicKey: keypair.publicKey)
            }
        }
        
        return try MuteListEvent(content: encryptedContent ?? "", tags: publicTags, signedBy: keypair)
    }
}
