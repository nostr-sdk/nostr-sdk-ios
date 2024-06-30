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

extension NostrEvent: MetadataCoding, RelayURLValidating {
    private static let bech32NoteIdPrefix = "note"

    /// Gets a bare `note`-prefixed bech32-formatted human-friendly id of this event, or `nil` if it could not be generated.
    /// It is not meant to be used inside the standard NIP-01 event formats or inside the filters.
    /// They are meant for human-friendlier display and input only.
    /// Clients should still accept keys in both hex and npub format and convert internally.
    ///
    /// > Note: [NIP-19 bech32-encoded entities](https://github.com/nostr-protocol/nips/blob/master/19.md)
    public var bech32NoteId: String? {
        guard let data = id.hexDecoded else {
            return nil
        }
        return Bech32.encode(Bech32IdentifierType.note.rawValue, baseEightData: data)
    }

    /// Gets a shareable human-interactable event identifier for this event.
    /// The identifier is bech32-formatted with a prefix of `nevent` using a binary-encoded list of TLV (type-length-value).
    /// The identifier has all the information needed for the event to be found, which includes the
    /// event id, optionally the relays, optionally the author's public key, and optionally the event kind number.
    /// - Parameters:
    ///   - relayURLs: The String representations of relay URLs in which the event is more likely to be found, encoded as ASCII.
    ///   - excludeAuthor: Whether the author public key should be excluded from the identifier.
    ///   - excludeKind: Whether the event kind number should be excluded from the identifier.
    /// - Throws: `URLError.Code.badURL`, `RelayURLError.invalidScheme`, `TLVCodingError.failedToEncode`
    ///
    /// > Note: [NIP-19 bech32-encoded entities](https://github.com/nostr-protocol/nips/blob/master/19.md)
    public func shareableEventIdentifier(relayURLStrings: [String]? = nil, excludeAuthor: Bool = false, excludeKind: Bool = false) throws -> String {
        let validatedRelayURLStrings = try relayURLStrings?.map {
            try validateRelayURLString($0)
        }.map { $0.absoluteString }

        var metadata = Metadata(relays: validatedRelayURLStrings, eventId: id)
        if !excludeAuthor {
            metadata.pubkey = pubkey
        }
        if !excludeKind {
            metadata.kind = UInt32(kind.rawValue)
        }

        return try encodedIdentifier(with: metadata, identifierType: .event)
    }
}
