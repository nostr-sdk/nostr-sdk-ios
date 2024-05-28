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
public class NostrEvent: Codable, Equatable, Hashable {
    public static func == (lhs: NostrEvent, rhs: NostrEvent) -> Bool {
        lhs.id == rhs.id &&
        lhs.pubkey == rhs.pubkey &&
        lhs.createdAt == rhs.createdAt &&
        lhs.kind == rhs.kind &&
        lhs.tags == rhs.tags &&
        lhs.content == rhs.content &&
        lhs.signature == rhs.signature
    }
    
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
    public let signature: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case pubkey
        case createdAt = "created_at"
        case kind
        case tags
        case content
        case signature = "sig"
    }
    
    init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pubkey)
        hasher.combine(createdAt)
        hasher.combine(kind)
        hasher.combine(tags)
        hasher.combine(content)
        hasher.combine(signature)
    }

    /// The date the event was created.
    public var createdDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }
    
    /// The event serialized, so that it can be signed.
    public var serialized: String {
        EventSerializer.serializedEvent(withPubkey: pubkey,
                                        createdAt: createdAt,
                                        kind: kind.rawValue,
                                        tags: tags,
                                        content: content)
    }
    
    /// The event.id calculated as a SHA256 of the serialized event. See ``EventSerializer``.
    public var calculatedId: String {
        EventSerializer.identifierForEvent(withPubkey: pubkey,
                                           createdAt: createdAt,
                                           kind: kind.rawValue,
                                           tags: tags,
                                           content: content)
    }

    /// The event is a rumor if it is an unsigned event, where `signature` is `nil`.
    public var isRumor: Bool {
        signature == nil
    }

    /// Creates a copy of this event and makes it into a rumor ``NostrEvent``, where `signature` is `nil`.
    public var rumor: NostrEvent {
        NostrEvent(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: nil)
    }

    /// All tags with the provided name.
    public func allTags(withTagName tagName: TagName) -> [Tag] {
        tags.filter { $0.name == tagName.rawValue }
    }
    
    /// The first String value for the provided ``TagName``, if it exists.
    public func firstValueForTagName(_ tag: TagName) -> String? {
        firstValueForRawTagName(tag.rawValue)
    }
    
    /// The first String value for the provided raw tag name, if it exists.
    public func firstValueForRawTagName(_ tagName: String) -> String? {
        tags.first(where: { $0.name == tagName })?.value
    }
    
    /// All values for tags with the provided name.
    /// - Parameter tag: The tag name to filter.
    /// - Returns: The values associated with the tags of the provided name.
    public func allValues(forTagName tag: TagName) -> [String] {
        tags.filter { $0.name == tag.rawValue }.map { $0.value }
    }
}
