//
//  NostrEvent.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

public struct NostrEvent: Codable {
    public let id: String
    public let pubkey: String
    public let createdAt: TimeInterval
    public let kind: EventKind
    public let tags: [EventTag]
    public let content: String
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

    public var createdDate: Date {
        Date(timeIntervalSince1970: createdAt)
    }
}
