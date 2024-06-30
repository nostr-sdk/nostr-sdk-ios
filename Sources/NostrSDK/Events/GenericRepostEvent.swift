//
//  GenericRepostEvent.swift
//  
//
//  Created by Bryan Montz on 8/3/23.
//

import Foundation

/// A generic repost event (kind 16) can include any kind of event inside other than kind 1.
/// > Note: Generic reposts SHOULD contain a `k` tag with the stringified kind number of the reposted event as its value.
/// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#generic-reposts).
public class GenericRepostEvent: NostrEvent {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: Self.kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    class var kind: EventKind {
        .genericRepost
    }
    
    /// The pubkey of the reposted event.
    var repostedEventPubkey: String? {
        firstValueForTagName(.pubkey)
    }
    
    /// The note that is being reposted.
    var repostedEvent: NostrEvent? {
        let jsonData = Data(content.utf8)
        guard let note: NostrEvent = try? JSONDecoder().decode(NostrEvent.self, from: jsonData) else {
            return nil
        }
        return note
    }
    
    /// The id of the event that is being reposted.
    var repostedEventId: String? {
        firstValueForTagName(.event)
    }
    
    /// The relay URL at which to fetch the reposted event.
    var repostedEventRelayURL: URL? {
        guard let eventTag = tags.first(where: { $0.name == TagName.event.rawValue }),
              let relayString = eventTag.otherParameters.first else {
            return nil
        }

        return try? validateRelayURLString(relayString)
    }
}

public extension EventCreating {
    
    /// Creates a ``TextNoteRepostEvent`` (kind 6) or ``GenericRepostEvent`` (kind 16) based on the kind of the event being reposted and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - event: The event to repost.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TextNoteRepostEvent`` or ``GenericRepostEvent``.
    ///
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#reposts).
    func repost(event: NostrEvent, signedBy keypair: Keypair) throws -> GenericRepostEvent {
        let jsonData = try JSONEncoder().encode(event)
        let stringifiedJSON = String(decoding: jsonData, as: UTF8.self)
        var tags: [Tag] = [
            .event(event.id),
            .pubkey(event.pubkey)
        ]
        if event.kind == .textNote {
            return try TextNoteRepostEvent(content: stringifiedJSON, tags: tags, signedBy: keypair)
        } else {
            tags.append(.kind(event.kind))
            
            return try GenericRepostEvent(content: stringifiedJSON, tags: tags, signedBy: keypair)
        }
    }
}
