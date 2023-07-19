//
//  NostrEvent.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

/// A structure that describes a Nostr event.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/master/01.md#events-and-signatures)
public struct NostrEvent: Codable {
    
    /// 32-byte, lowercase, hex-encoded sha256 of the serialized event data
    public let id: String
    
    /// 32-byte, lowercase, hex-encoded public key of the event creator
    public let pubkey: String
    
    /// unix timestamp in seconds
    public let createdAt: Int64
    
    /// integer
    public let kind: EventKind
    
    /// list of tags, see ``Tag``
    public let tags: [Tag]
    
    /// arbitrary string
    public let content: String
    
    /// 64-byte hex of the signature of the sha256 hash of the serialized event data, which is the same as the "id" field
    public let signature: String

    private enum CodingKeys: String, CodingKey {
        case id
        case pubkey
        case createdAt = "created_at"
        case kind
        case tags
        case content
        case signature = "sig"
    }
    
    init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String) {
        self.id = id
        self.pubkey = pubkey
        self.createdAt = createdAt
        self.kind = kind
        self.tags = tags
        self.content = content
        self.signature = signature
    }
    
    init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        self.kind = kind
        self.content = content
        self.tags = tags
        self.createdAt = createdAt
        pubkey = keypair.publicKey.hex
        id = EventSerializer.identifierForEvent(withPubkey: keypair.publicKey.hex,
                                                createdAt: createdAt,
                                                kind: kind.rawValue,
                                                tags: tags,
                                                content: content)
        signature = try keypair.privateKey.signatureForContent(id)
    }
    
    /// the date the event was created
    public var createdDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
    
    /// the event serialized, so that it can be signed
    public var serialized: String {
        EventSerializer.serializedEvent(withPubkey: pubkey,
                                        createdAt: createdAt,
                                        kind: kind.rawValue,
                                        tags: tags,
                                        content: content)
    }
    
    /// the event.id calculated as a SHA256 of the serialized event. See ``EventSerializer``.
    public var calculatedId: String {
        EventSerializer.identifierForEvent(withPubkey: pubkey,
                                           createdAt: createdAt,
                                           kind: kind.rawValue,
                                           tags: tags,
                                           content: content)
    }
}
