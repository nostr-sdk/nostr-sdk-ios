//
//  Filter.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

public struct Filter: Codable {
    public let ids: [String]?
    public let authors: [String]?
    public let kinds: [Int]?
    public let events: [String]?
    public let pubkeys: [String]?
    public let since: Int?
    public let until: Int?
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
