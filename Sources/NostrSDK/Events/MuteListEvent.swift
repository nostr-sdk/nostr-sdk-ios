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
public final class MuteListEvent: NostrEvent, HashtagInterpreting, DirectMessageEncrypting, NonParameterizedReplaceableEvent {
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
        allValues(forTagName: .pubkey) ?? []
    }
    
    /// The publicly muted event ids (threads).
    public var eventIds: [String] {
        allValues(forTagName: .event) ?? []
    }
    
    /// The publicly muted keywords.
    public var keywords: [String] {
        allValues(forTagName: .word) ?? []
    }
    
    /// The privately muted public keys (authors).
    public func privatePubkeys(using keypair: Keypair) -> [String] {
        privateTags(withName: .pubkey, using: keypair)
    }
    
    /// The privately muted event ids (threads).
    public func privateEventIds(using keypair: Keypair) -> [String] {
        privateTags(withName: .event, using: keypair)
    }
    
    /// The privately muted hashtags.
    public func privateHashtags(using keypair: Keypair) -> [String] {
        privateTags(withName: .hashtag, using: keypair)
    }
    
    /// The privately muted keywords.
    public func privateKeywords(using keypair: Keypair) -> [String] {
        privateTags(withName: .word, using: keypair)
    }
    
    private func privateTags(withName tagName: TagName, using keypair: Keypair) -> [String] {
        privateTags(using: keypair).filter { $0.name == tagName.rawValue }.map { $0.value }
    }
    
    /// The private tags encrypted in the content of the event.
    /// - Parameter keypair: The keypair to use to decrypt the content.
    /// - Returns: The private tags.
    func privateTags(using keypair: Keypair) -> [Tag] {
        guard let decryptedContent = try? decrypt(encryptedContent: content, privateKey: keypair.privateKey, publicKey: keypair.publicKey),
              let jsonData = decryptedContent.data(using: .utf8) else {
            return []
        }
        
        let tags = try? JSONDecoder().decode([Tag].self, from: jsonData)
        return tags ?? []
    }
}
