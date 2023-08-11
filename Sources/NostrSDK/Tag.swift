//
//  Tag.swift
//  
//
//  Created by Bryan Montz on 5/23/23.
//

import Foundation

/// A constant that describes the type of a ``Tag``.
public enum TagName: Codable, Equatable {
    
    /// points to the id of an event this event is quoting, replying to or referring to somehow
    case event
    
    /// points to a pubkey of someone that is referred to in the event
    case pubkey
    
    /// a stringified kind number
    case kind
    
    /// a tag of unknown type
    case unknown(String)
    
    var rawValue: String {
        switch self {
        case .event:
            return "e"
        case .pubkey:
            return "p"
        case .kind:
            return "k"
        case .unknown(let id):
            return id
        }
    }
    
    public static func == (lhs: TagName, rhs: TagName) -> Bool {
        switch (lhs, rhs) {
        case (.event, .event), (.pubkey, .pubkey), (.kind, .kind): return true
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

/// A reference to an event, pubkey, or other content.
///
/// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md) for an initial definition of tags.
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/01.md) for further refinement and additions to tags.
/// See https://github.com/nostr-protocol/nips/tree/b4cdc1a73d415c79c35655fa02f5e55cd1f2a60c#standardized-tags for a list of all standardized tags.
public class Tag: Codable, Equatable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
    /// The name of the tag: event, pubkey, kind etc.
    let name: TagName
    
    /// The main value associated with the tag. For example, for the
    /// pubkey name, the `value` is the 32-byte, hex-encoded pubkey.
    let value: String
    
    /// The remaining parameters in the array of strings the tag consists of.
    let otherParameters: [String]
    
    /// Creates and returns a ``Tag`` object that references some piece of content.
    /// - Parameters:
    ///   - name: The name of the tag: event, pubkey, or other unknown type.
    ///   - value: The content identifier associated with the type. For example, for the
    ///                        pubkey type, the `value` is the 32-byte, hex-encoded pubkey.
    ///   - otherParameters: The remaining parameters in the array of strings the tag consists of.
    public init(name: TagName, value: String, otherParameters: [String] = []) {
        self.name = name
        self.value = value
        self.otherParameters = otherParameters
    }
    
    required public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        let type = try container.decode(String.self)
        switch type {
        case "p":
            name = .pubkey
        case "e":
            name = .event
        case "k":
            name = .kind
        default:
            name = .unknown(type)
        }
        
        value = try container.decode(String.self)
        
        var otherParameters = [String]()
        while !container.isAtEnd {
            let value = try container.decode(String.self)
            otherParameters.append(value)
        }
        self.otherParameters = otherParameters
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(name.rawValue)
        try container.encode(value)
        for value in otherParameters {
            try container.encode(value)
        }
    }
    
    func isEqual(to tag: Tag) -> Bool {
        name == tag.name &&
        value == tag.value &&
        otherParameters == tag.otherParameters
    }
}
