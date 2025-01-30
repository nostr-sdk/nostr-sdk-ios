//
//  Tag.swift
//  
//
//  Created by Bryan Montz on 5/23/23.
//

import Foundation

/// A constant that describes the type of a ``Tag``.
public enum TagName: String {

    /// A short human-readable plaintext summary of what the event is about
    /// when the event kind is part of a custom protocol and isn't meant to be read as text (like kind:1).
    /// See [NIP-31 - Dealing with unknown event kinds](https://github.com/nostr-protocol/nips/blob/master/31.md).
    case alternativeSummary = "alt"

    /// a custom emoji that defines the shortcode name and image URL of the image file
    case emoji
    
    /// points to the id of an event this event is quoting, replying to or referring to somehow
    case event = "e"

    /// coordinates to a replaceable event, which includes the kind number, pubkey that signed the event, and optionally the identifier (if the replaceable event is parameterized)
    case eventCoordinates = "a"

    /// Specifies a unix timestamp at which the message SHOULD be considered expired (by relays and clients) and SHOULD be deleted by relays.
    /// See [NIP-40 - Expiration Timestamp](https://github.com/nostr-protocol/nips/blob/master/40.md).
    case expiration

    /// a hashtag to categorize events for easy searching
    case hashtag = "t"
    
    /// points to a pubkey of someone that is referred to in the event
    case pubkey = "p"
    
    case publishedAt = "published_at"
    
    case identifier = "d"
    
    case image
    
    /// a stringified kind number
    case kind = "k"

    /// labels other entities
    case label = "l"

    /// namespace for a label
    case labelNamespace = "L"

    /// a short subject for a text note, similar to subjects in emails
    case subject
    
    case summary
    
    /// a title for an event
    case title
    
    /// a web URL the event is referring to in some way. See [NIP-24 - Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#tags).
    case webURL = "r"
    
    /// a keyword to mute
    case word
}

/// A reference to an event, pubkey, or other content.
///
/// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md) for an initial definition of tags.
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md) for further refinement and additions to tags.
/// See https://github.com/nostr-protocol/nips/tree/b4cdc1a73d415c79c35655fa02f5e55cd1f2a60c#standardized-tags for a list of all standardized tags.
public class Tag: Codable, Equatable, Hashable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name == rhs.name &&
        lhs.value == rhs.value &&
        lhs.otherParameters == rhs.otherParameters
    }
    
    /// The name of the tag.
    public let name: String

    /// The main value associated with the tag. For example, for the
    /// pubkey name, the `value` is the 32-byte, hex-encoded pubkey.
    public let value: String

    /// The remaining parameters in the array of strings the tag consists of.
    public let otherParameters: [String]

    /// Creates and returns a ``Tag`` object that references some piece of content.
    /// - Parameters:
    ///   - name: The name of the tag.
    ///   - value: The content identifier associated with the type. For example, for the
    ///                        pubkey type, the `value` is the 32-byte, hex-encoded pubkey.
    ///   - otherParameters: The remaining parameters in the array of strings the tag consists of.
    init(name: String, value: String, otherParameters: [String] = []) {
        self.name = name
        self.value = value
        self.otherParameters = otherParameters
    }

    /// Creates and returns a ``Tag`` object that references some piece of content.
    /// - Parameters:
    ///   - name: The name of the tag: event, pubkey, kind etc.
    ///   - value: The content identifier associated with the type. For example, for the
    ///                        pubkey type, the `value` is the 32-byte, hex-encoded pubkey.
    ///   - otherParameters: The remaining parameters in the array of strings the tag consists of.
    convenience init(name: TagName, value: String, otherParameters: [String] = []) {
        self.init(name: name.rawValue, value: value, otherParameters: otherParameters)
    }

    required public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        name = try container.decode(String.self)
        value = try container.decode(String.self)
        
        var otherParameters = [String]()
        while !container.isAtEnd {
            let value = try container.decode(String.self)
            otherParameters.append(value)
        }
        self.otherParameters = otherParameters
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(otherParameters)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(name)
        try container.encode(value)
        for value in otherParameters {
            try container.encode(value)
        }
    }
    
    /// The raw format of a tag, which can be serialized and transmitted.
    ///
    /// For example:
    /// An "e" tag (event tag), has a 32-byte event id as the first value and can optionally have a relay URL after that. So its raw value would look like:
    /// [ "e", "1dc8b913d9d4f50a71182dc9232996d6fbc69e8c955866e43ef2c2e35185bbfa", "wss://www.relay.com" ]
    var raw: [String] {
        [name, value] + otherParameters
    }
}

/// Shortcuts for creating common tags
extension Tag {
    
    /// An event ``Tag`` with the provided id and other parameters.
    /// - Parameters:
    ///   - eventId: The event id.
    ///   - otherParameters: The other parameters.
    /// - Returns: The event ``Tag``.
    static func event(_ eventId: String, otherParameters: [String] = []) -> Tag {
        Tag(name: .event, value: eventId, otherParameters: otherParameters)
    }
    
    /// A hashtag ``Tag`` with the provided value.
    /// - Parameter hashtag: The hashtag.
    /// - Returns: The hashtag ``Tag``.
    static func hashtag(_ hashtag: String) -> Tag {
        Tag(name: .hashtag, value: hashtag)
    }
    
    /// A kind ``Tag`` with the provided value.
    /// - Parameter kind: The kind (``EventKind``).
    /// - Returns: The kind ``Tag``.
    static func kind(_ kind: EventKind) -> Tag {
        Tag(name: .kind, value: String(kind.rawValue))
    }
    
    /// A pubkey ``Tag`` with the provided pubkey.
    /// - Parameters:
    ///   - pubkey: The pubkey.
    ///   - otherParameters: The other parameters.
    /// - Returns: The pubkey ``Tag``.
    static func pubkey(_ pubkey: String, otherParameters: [String] = []) -> Tag {
        Tag(name: .pubkey, value: pubkey, otherParameters: otherParameters)
    }
    
    static func link(_ url: URL) -> Tag {
        Tag(name: .webURL, value: url.absoluteString)
    }
}

extension Tag: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tag(name: \"\(name)\", value: \"\(value)\", otherParameters: \(otherParameters)"
    }
}
