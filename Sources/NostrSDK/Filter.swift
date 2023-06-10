//
//  Filter.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

/// A structure that describes a filter to subscribe to relays with.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/master/01.md)
public struct Filter: Codable {
    /// a list of event ids or prefixes
    public let ids: [String]?
    
    /// a list of pubkeys or prefixes, the pubkey of an event must be one of these
    public let authors: [String]?
    
    /// a list of a kind numbers
    public let kinds: [Int]?
    
    /// a list of event ids that are referenced in an "e" tag
    public let events: [String]?
    
    /// a list of pubkeys that are referenced in a "p" tag
    public let pubkeys: [String]?
    
    /// an integer unix timestamp, events must be newer than this to pass
    public let since: Int?
    
    /// an integer unix timestamp, events must be older than this to pass
    public let until: Int?
    
    /// maximum number of events to be returned in the initial query
    public let limit: Int?

    private enum CodingKeys: String, CodingKey {
        case ids = "ids"
        case authors = "authors"
        case kinds = "kinds"
        case events = "#e"
        case pubkeys = "#p"
        case since = "since"
        case until = "until"
        case limit = "limit"
    }
    
    /// Creates the filter with the specified parameters
    ///
    /// - Parameters:
    ///   - ids: a list of event ids or prefixes
    ///   - authors: a list of pubkeys or prefixes, the pubkey of an event must be one of these
    ///   - kinds: a list of a kind numbers
    ///   - events: a list of event ids that are referenced in an "e" tag
    ///   - pubkeys: a list of pubkeys that are referenced in a "p" tag
    ///   - since: an integer unix timestamp, events must be newer than this to pass
    ///   - until: an integer unix timestamp, events must be older than this to pass
    ///   - limit: maximum number of events to be returned in the initial query
    ///
    ///   > Important: Event ids and pubkeys should be in the 32-byte hexadecimal format, not the `note...` and `npub...` formats
    public init(ids: [String]? = nil, authors: [String]? = nil, kinds: [Int]? = nil, events: [String]? = nil, pubkeys: [String]? = nil, since: Int? = nil, until: Int? = nil, limit: Int? = nil) {
        self.ids = ids
        self.authors = authors
        self.kinds = kinds
        self.events = events
        self.pubkeys = pubkeys
        self.since = since
        self.until = until
        self.limit = limit
    }
}
