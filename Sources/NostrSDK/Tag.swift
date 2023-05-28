//
//  Tag.swift
//  
//
//  Created by Bryan Montz on 5/23/23.
//

// NIP 1 - initial definition of tags
// https://github.com/nostr-protocol/nips/blob/master/01.md
//
// NIP 10 - refinement of tags
// https://github.com/nostr-protocol/nips/blob/master/10.md

import Foundation

public enum TagIdentifier: Codable, Equatable {
    case event
    case pubkey
    case unknown(String)
    
    var rawValue: String {
        switch self {
        case .event:
            return "e"
        case .pubkey:
            return "p"
        case .unknown(let id):
            return id
        }
    }
    
    public static func == (lhs: TagIdentifier, rhs: TagIdentifier) -> Bool {
        switch (lhs, rhs) {
        case (.event, .event), (.pubkey, .pubkey): return true
        case (.unknown(let id1), .unknown(let id2)): return id1 == id2
        default: return false
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(rawValue)
    }
}

public enum EventTagMarker: Codable, Equatable {
    case root, reply, mention, unknown(String)
    
    init(rawValue: String) {
        switch rawValue {
        case "root":
            self = .root
        case "reply":
            self = .reply
        case "mention":
            self = .mention
        default:
            self = .unknown(rawValue)
        }
    }
    
    var rawValue: String {
        switch self {
        case .root:
            return "root"
        case .reply:
            return "reply"
        case .mention:
            return "mention"
        case .unknown(let id):
            return id
        }
    }
    
    public static func == (lhs: EventTagMarker, rhs: EventTagMarker) -> Bool {
        switch (lhs, rhs) {
        case (.root, .root), (.reply, .reply), (.mention, .mention): return true
        case (.unknown(let id1), .unknown(let id2)): return id1 == id2
        default: return false
        }
    }
}

public class Tag: Codable, Equatable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
    let identifier: TagIdentifier
    let contentIdentifier: String
    
    init(identifier: TagIdentifier, contentIdentifier: String) {
        self.identifier = identifier
        self.contentIdentifier = contentIdentifier
    }
    
    required public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        let type = try container.decode(String.self)
        switch type {
        case "p":
            identifier = .pubkey
        case "e":
            identifier = .event
        default:
            identifier = .unknown(type)
        }
        
        contentIdentifier = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(identifier.rawValue)
        try container.encode(contentIdentifier)
    }
    
    func isEqual(to tag: Tag) -> Bool {
        identifier == tag.identifier &&
        contentIdentifier == tag.contentIdentifier
    }
}

public class PubkeyTag: Tag {
    let recommendedRelayURL: String?
    let petname: String?
    
    init(contentIdentifier: String, recommendedRelayURL: String? = nil, petname: String? = nil) {
        self.recommendedRelayURL = recommendedRelayURL
        self.petname = petname
        super.init(identifier: .pubkey, contentIdentifier: contentIdentifier)
    }
    
    public required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        recommendedRelayURL = try container.decodeIfPresent(String.self)
        petname = try container.decodeIfPresent(String.self)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.unkeyedContainer()
        if let recommendedRelayURL {
            try container.encode(recommendedRelayURL)
        }
        if let petname {
            try container.encode(petname)
        }
    }
    
    override func isEqual(to tag: Tag) -> Bool {
        guard let pTag = tag as? PubkeyTag else {
            return false
        }
        return super.isEqual(to: tag) &&
               recommendedRelayURL == pTag.recommendedRelayURL &&
               petname == pTag.petname
    }
}

public class EventTag: Tag {
    let marker: EventTagMarker?
    
    init(contentIdentifier: String, marker: EventTagMarker? = nil) {
        self.marker = marker
        super.init(identifier: .event, contentIdentifier: contentIdentifier)
    }
    
    public required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        if let rawMarker = try container.decodeIfPresent(String.self) {
            marker = EventTagMarker(rawValue: rawMarker)
        } else {
            marker = nil
        }
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.unkeyedContainer()
        if let marker {
            try container.encode(marker)
        }
    }
    
    override func isEqual(to tag: Tag) -> Bool {
        guard let eTag = tag as? EventTag else {
            return false
        }
        return super.isEqual(to: tag) &&
               marker == eTag.marker
    }
}
