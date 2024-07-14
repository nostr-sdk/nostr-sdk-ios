//
//  Filter.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

/// A structure that describes a filter to subscribe to relays with.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/master/01.md#communication-between-clients-and-relays)
public struct Filter: Codable, Hashable, Equatable {
    /// a list of event ids
    public let ids: [String]?
    
    /// a list of lowercase pubkeys, the pubkey of an event must be one of these
    public let authors: [String]?
    
    /// a list of a kind numbers
    public let kinds: [Int]?

    /// a list of tag values that are referenced by single basic Latin letter tag names
    public let tags: [Character: [String]]?

    /// an integer unix timestamp, `created_at` timestamps on events must be greater than or equal to this to pass
    public let since: Int?
    
    /// an integer unix timestamp, `created_at` timestamps on events must be less than or equal to this to pass
    public let until: Int?
    
    /// maximum number of events to be returned in the initial query
    public let limit: Int?

    private enum CodingKeys: String, CodingKey {
        case ids
        case authors
        case kinds
        case since
        case until
        case limit
    }

    private struct TagFilterName: CodingKey {
        let stringValue: String

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int? { nil }

        init?(intValue: Int) {
            return nil
        }
    }

    /// Creates and returns a filter with the specified parameters.
    ///
    /// - Parameters:
    ///   - ids: a list of event ids
    ///   - authors: a list of lowercase pubkeys, the pubkey of an event must be one of these
    ///   - kinds: a list of a kind numbers
    ///   - events: a list of event ids that are referenced in an "e" tag
    ///   - pubkeys: a list of pubkeys that are referenced in a "p" tag
    ///   - tags: a list of tag values that are referenced by single basic Latin letter tag names
    ///   - since: an integer unix timestamp, `created_at` timestamps on events must be greater than or equal to this to pass
    ///   - until: an integer unix timestamp,`created_at` timestamps on events must be less than or equal to this to pass
    ///   - limit: maximum number of events to be returned in the initial query
    ///
    /// If `tags` contains an `e` tag and `events` is also provided, `events` takes precedence.
    /// If `tags` contains a `p` tag and `pubkeys` is also provided, `pubkeys` takes precedence.
    ///
    /// Returns `nil` if `tags` contains tag names that are not in the basic Latin alphabet of A-Z or a-z.
    ///
    /// > Important: The `ids`, `authors`, `events`, and `pubkeys` filter lists MUST contain exact 64-character lowercase hex values.
    public init?(ids: [String]? = nil, authors: [String]? = nil, kinds: [Int]? = nil, events: [String]? = nil, pubkeys: [String]? = nil, tags: [Character: [String]]? = nil, since: Int? = nil, until: Int? = nil, limit: Int? = nil) {
        self.ids = ids
        self.authors = authors
        self.kinds = kinds
        self.since = since
        self.until = until
        self.limit = limit

        if let tags {
            guard tags.keys.allSatisfy({ $0.isBasicLatinLetter }) else {
                return nil
            }
        }

        var tagsBuilder: [Character: [String]] = tags ?? [:]
        if let events {
            tagsBuilder["e"] = events
        }
        if let pubkeys {
            tagsBuilder["p"] = pubkeys
        }
        self.tags = tagsBuilder
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        ids = try container.decodeIfPresent([String].self, forKey: .ids)
        authors = try container.decodeIfPresent([String].self, forKey: .authors)
        kinds = try container.decodeIfPresent([Int].self, forKey: .kinds)
        since = try container.decodeIfPresent(Int.self, forKey: .since)
        until = try container.decodeIfPresent(Int.self, forKey: .until)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)

        if let tagsContainer = try? decoder.container(keyedBy: TagFilterName.self) {
            var decodedTags: [Character: [String]] = [:]
            for key in tagsContainer.allKeys {
                let tagName = key.stringValue

                if tagName.count == 2 && tagName.first == "#", let tagCharacter = tagName.last, tagCharacter.isBasicLatinLetter {
                    decodedTags[tagCharacter] = try tagsContainer.decode([String].self, forKey: key)
                }
            }
            tags = decodedTags.isEmpty ? nil : decodedTags
        } else {
            tags = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(self.ids, forKey: .ids)
        try container.encodeIfPresent(self.authors, forKey: .authors)
        try container.encodeIfPresent(self.kinds, forKey: .kinds)
        try container.encodeIfPresent(self.since, forKey: .since)
        try container.encodeIfPresent(self.until, forKey: .until)
        try container.encodeIfPresent(self.limit, forKey: .limit)

        var tagsContainer = encoder.container(keyedBy: TagFilterName.self)
        try self.tags?.forEach {
            try tagsContainer.encode($0.value, forKey: TagFilterName(stringValue: "#\($0.key)"))
        }
    }
}

private extension Character {
    var isBasicLatinLetter: Bool {
        (self >= "A" && self <= "Z") || (self >= "a" && self <= "z")
    }
}
