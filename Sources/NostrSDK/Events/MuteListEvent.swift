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
public final class MuteListEvent: NostrEvent, HashtagInterpreting, DirectMessageEncrypting {
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
    
    /// The publicly muted hashtags.
    public var hashtags: [String] {
        allValues(forTagName: .hashtag) ?? []
    }
    
    /// The publicly muted keywords.
    public var keywords: [String] {
        allValues(forTagName: .word) ?? []
    }
    
    /// The secretly muted public keys (authors).
    public func secretPubkeys(using keypair: Keypair) -> [String] {
        secretTags(withName: .pubkey, using: keypair)
    }
    
    /// The secretly muted event ids (threads).
    public func secretEventIds(using keypair: Keypair) -> [String] {
        secretTags(withName: .event, using: keypair)
    }
    
    /// The secretly muted hashtags.
    public func secretHashtags(using keypair: Keypair) -> [String] {
        secretTags(withName: .hashtag, using: keypair)
    }
    
    /// The secretly muted keywords.
    public func secretKeywords(using keypair: Keypair) -> [String] {
        secretTags(withName: .word, using: keypair)
    }
    
    private func secretTags(withName tagName: TagName, using keypair: Keypair) -> [String] {
        secretTags(using: keypair).filter { $0.name == tagName.rawValue }.map { $0.value }
    }
    
    /// The secret tags encrypted in the content of the event.
    /// - Parameter keypair: The keypair to use to decrypt the content.
    /// - Returns: The secret tags.
    func secretTags(using keypair: Keypair) -> [Tag] {
        guard let decryptedContent = try? decrypt(encryptedContent: content, privateKey: keypair.privateKey, publicKey: keypair.publicKey),
              let jsonData = decryptedContent.data(using: .utf8) else {
            return []
        }
        
        let tags = try? JSONDecoder().decode([Tag].self, from: jsonData)
        return tags ?? []
    }
}
