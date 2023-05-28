//
//  Filter.swift
//  
//
//  Created by Joel Klabo on 5/26/23.
//

import Foundation

struct Filter: Codable {
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
