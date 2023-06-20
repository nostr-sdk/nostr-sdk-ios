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
    public let createdAt: TimeInterval
    
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
    
    /// the date the event was created
    public var createdDate: Date {
        Date(timeIntervalSince1970: createdAt)
    }
    
    /// the serialized event
    ///
    /// To obtain the `event.id`, we sha256 the serialized event. The serialization is done over the UTF-8 JSON-serialized string (with no white space or line breaks) of the following structure:
    ///
    /// ```json
    /// [
    ///    0,
    ///    <pubkey, as a (lowercase) hex string>,
    ///    <created_at, as a number>,
    ///    <kind, as a number>,
    ///    <tags, as an array of arrays of non-null strings>,
    ///    <content, as a string>
    /// ]
    /// ```
    ///
    /// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md#events-and-signatures).
    public var serializedForSigning: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        let tagsString: String
        if let tagsData = try? encoder.encode(tags) {
            tagsString = String(decoding: tagsData, as: UTF8.self)
        } else {
            tagsString = "[]"
        }
        
        let contentString: String
        if let contentData = try? encoder.encode(content) {
            contentString = String(decoding: contentData, as: UTF8.self)
        } else {
            contentString = "\"\""
        }
        return "[0,\"\(pubkey)\",\(Int64(createdAt)),\(kind.rawValue),\(tagsString),\(contentString)]"
    }
}
