//
//  Filter.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

struct Filter {
    let ids: [String]?
    let authors: [String]?
    let kinds: [Int]?
    let events: [String]?
    let pubkeys: [String]?
    let since: Int?
    let until: Int?
    let limit: Int?

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
}

extension Filter: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ids = try container.decodeIfPresent([String].self, forKey: .ids)
        authors = try container.decodeIfPresent([String].self, forKey: .authors)
        kinds = try container.decodeIfPresent([Int].self, forKey: .kinds)
        events = try container.decodeIfPresent([String].self, forKey: .events)
        pubkeys = try container.decodeIfPresent([String].self, forKey: .pubkeys)
        since = try container.decodeIfPresent(Int.self, forKey: .since)
        until = try container.decodeIfPresent(Int.self, forKey: .until)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(ids, forKey: .ids)
        try container.encodeIfPresent(authors, forKey: .authors)
        try container.encodeIfPresent(kinds, forKey: .kinds)
        try container.encodeIfPresent(events, forKey: .events)
        try container.encodeIfPresent(pubkeys, forKey: .pubkeys)
        try container.encodeIfPresent(since, forKey: .since)
        try container.encodeIfPresent(until, forKey: .until)
        try container.encodeIfPresent(limit, forKey: .limit)
    }
}
