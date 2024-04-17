//
//  FollowListEvent.swift
//
//
//  Created by Bryan Montz on 8/3/23.
//

import Foundation

/// Describes the permissions that a user has for a given relay.
public struct RelayPermissions: Equatable {
    
    /// Whether or not the user can read from the relay.
    public let read: Bool
    
    /// Whether or not the user cn write to the relay.
    public let write: Bool
    
    init(read: Bool, write: Bool) {
        self.read = read
        self.write = write
    }
    
    init(dictionary: [AnyHashable: Any]) {
        read = dictionary["read"] as? Bool ?? false
        write = dictionary["write"] as? Bool ?? false
    }
}

/// A special event with kind 3, meaning "follow list" is defined as having a list of p tags, one for each of the followed/known profiles one is following.
///
/// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md)
public final class FollowListEvent: NostrEvent, NonParameterizedReplaceableEvent {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .followList, content: "", tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Pubkeys for followed/known profiles.
    public var followedPubkeys: [String] {
        allValues(forTagName: .pubkey)
    }
    
    /// Pubkey tags for followed/known profiles.
    public var followedPubkeyTags: [Tag] {
        tags.filter({ $0.name == TagName.pubkey.rawValue })
    }
    
    /// Relays the user knows about.
    ///
    /// > Warning: This method of storing and accessing a user's relays is out of spec, not preferred,
    ///            and will be removed in the future. It is provided here for completeness and because of common usage.
    @available(*, deprecated, message: "This method of storing and accessing a user's relays is out of spec, not preferred, and will be removed in the future.")
    public var relays: [String: RelayPermissions] {
        guard let contentData = content.data(using: .utf8),
              let contentDictionary = try? JSONSerialization.jsonObject(with: contentData) as? [String: [AnyHashable: Any]] else {
            return [:]
        }
        return contentDictionary.reduce(into: [String: RelayPermissions]()) { partialResult, element in
            let (key, value) = element
            partialResult[key] = RelayPermissions(dictionary: value)
        }
    }
}

public extension EventCreating {
    
    /// Creates a ``FollowListEvent`` (kind 3) following the provided pubkeys and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - pubkeys: The pubkeys of followed/known profiles to add to the follow list, in hex format.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``FollowListEvent``.
    ///
    /// Use this initializer if you do not intend to include petnames as part of the follow list.
    ///
    /// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md)
    func followList(withPubkeys pubkeys: [String], signedBy keypair: Keypair) throws -> FollowListEvent {
        try followList(withPubkeyTags: pubkeys.map { .pubkey($0) },
                       signedBy: keypair)
    }
    
    /// Creates a ``FollowListEvent`` (kind 3) with the provided pubkey tags and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - pubkeyTags: The pubkey tags of followed/known profiles to add to the follow list, which may include petnames.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``FollowListEvent``.
    ///
    /// Use this initializer if you intend to include petnames as part of the follow list.
    ///
    /// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md)
    func followList(withPubkeyTags pubkeyTags: [Tag], signedBy keypair: Keypair) throws -> FollowListEvent {
        guard !pubkeyTags.contains(where: { $0.name != TagName.pubkey.rawValue }) else {
            throw EventCreatingError.invalidInput
        }
        return try FollowListEvent(tags: pubkeyTags,
                                   signedBy: keypair)
    }
}
