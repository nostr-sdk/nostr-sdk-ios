//
//  EventTag.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

public enum TagIdentifier: String, Codable {
    case event = "e"
    case pubkey = "p"
}

public struct EventTag: Codable, Equatable {
    public let identifier: TagIdentifier
    public let contentIdentifier: String
    public let recommendedRelayURL: String?

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let tagIdentifier = try container.decode(String.self)
        identifier = TagIdentifier(rawValue: tagIdentifier) ?? .event

        contentIdentifier = try container.decode(String.self)

        recommendedRelayURL = try container.decodeIfPresent(String.self)
    }

    init(identifier: TagIdentifier, contentIdentifier: String, recommendedRelayURL: String? = nil) {
        self.identifier = identifier
        self.contentIdentifier = contentIdentifier
        self.recommendedRelayURL = recommendedRelayURL
    }

    enum CodingKeys: CodingKey {
        case identifier
        case contentIdentifier
        case recommendedRelayURL
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.identifier.rawValue)
        try container.encode(self.contentIdentifier)
        if let url = self.recommendedRelayURL {
            try container.encode(url)
        }
    }
}
