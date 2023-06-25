//
//  EventSerializer.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation

public enum EventSerializer {
    
    /// Serializes properties of an event.
    ///
    /// The serialization is done over the UTF-8 JSON-serialized string (with no white space or line breaks) of the following structure:
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
    public static func serializedEvent(withPubkey pubkey: String, createdAt: Int64, kind: Int, tags: [Tag], content: String) -> String {
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
        return "[0,\"\(pubkey)\",\(createdAt),\(kind),\(tagsString),\(contentString)]"
    }
    
    /// To obtain the event.id, we SHA256 the serialized event.
    public static func identifierForEvent(withPubkey pubkey: String, createdAt: Int64, kind: Int, tags: [Tag], content: String) -> String {
        serializedEvent(withPubkey: pubkey,
                        createdAt: createdAt,
                        kind: kind,
                        tags: tags,
                        content: content).data(using: .utf8)!.sha256.hexString
    }
}
