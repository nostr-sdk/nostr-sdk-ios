//
//  Tag.swift
//  
//
//  Created by Bryan Montz on 5/23/23.
//

import Foundation

/// A constant that describes the type of a ``Tag``.
public enum TagIdentifier: Codable, Equatable {
    
    /// points to the id of an event this event is quoting, replying to or referring to somehow
    case event
    
    /// points to a pubkey of someone that is referred to in the event
    case pubkey
    
    /// a tag of unknown type
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

/// A constant that describes a type of reference to an event.
///
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md#marked-e-tags-preferred) for a description of marked "e" tags.
public enum EventTagMarker: Codable, Equatable {
    /// Denotes the root id of the reply thread being responded to.
    case root
    
    /// Denotes the id of the reply event being responded to.
    case reply
    
    /// Denotes a quoted or reposted event id.
    case mention
    
    /// Denotes an unknown marker type.
    case unknown(String)
    
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

/// A reference to an event, pubkey, or other content
///
/// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md) for an initial definition of tags.
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/01.md) for further refinement and additions to tags.
public class Tag: Codable, Equatable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
    /// The type of tag: event, pubkey, or other unknown type.
    let identifier: TagIdentifier
    
    /// The content identifier associated with the type. For example, for the
    /// pubkey type, the `contentIdentifier` is the 32-byte, hex-encoded pubkey.
    let contentIdentifier: String
    
    /// Creates and returns a tag object that references some piece of content.
    /// - Parameters:
    ///   - identifier: The type of tag: event, pubkey, or other unknown type.
    ///   - contentIdentifier: The content identifier associated with the type. For example, for the
    ///                        pubkey type, the `contentIdentifier` is the 32-byte, hex-encoded pubkey.
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

/// A tag referencing a pubkey
///
/// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md) and [NIP-02](https://github.com/nostr-protocol/nips/blob/master/02.md#contact-list-and-petnames)
public class PubkeyTag: Tag {
    /// The URL of a recommended relay associated with the reference.
    let recommendedRelayURL: String?
    
    /// A local name for the profile (can also be set to an empty string or not provided).
    let petname: String?
    
    /// Creates and returns a tag for a pubkey.
    /// - Parameters:
    ///   - contentIdentifier: The content identifier associated with the type. For example, for the
    ///                        pubkey type, the `contentIdentifier` is the 32-byte, hex-encoded pubkey.
    ///   - recommendedRelayURL: The URL of a recommended relay associated with the reference.
    ///   - petname: A local name for the profile (can also be set to an empty string or not provided).
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

/// A tag referencing an event
/// 
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md#marked-e-tags-preferred)
public class EventTag: Tag {
    /// The type of the ``EventTag``.
    let marker: EventTagMarker?
    
    /// Creates and returns tag referencing an event.
    /// - Parameters:
    ///   - contentIdentifier: The event id.
    ///   - marker: The type of reference. See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md#marked-e-tags-preferred) for a description of marked "e" tags.
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
