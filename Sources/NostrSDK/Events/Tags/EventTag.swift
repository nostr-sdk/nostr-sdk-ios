//
//  EventTag.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

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

enum EventTagError: Error {
    case invalidInput
}

/// Represents an "e" tag which is an event tag.
///
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md#marked-e-tags-preferred) for a description of marked "e" tags.
public struct EventTag: RelayProviding, RelayURLValidating, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag
    }

    /// The ``Tag`` that represents this event tag.
    public let tag: Tag

    /// The id of the event being referenced.
    public var eventId: String {
        tag.value
    }

    /// The URL of a recommended relay associated with the reference.
    public var relayURL: URL? {
        guard let relayString = tag.otherParameters.first, !relayString.isEmpty else {
            return nil
        }

        return try? validateRelayURLString(relayString)
    }

    /// The marker indicating the type of event tag.
    public var marker: EventTagMarker? {
        guard tag.otherParameters.count >= 2 else {
            return nil
        }

        return EventTagMarker(rawValue: tag.otherParameters[1])
    }

    /// The pubkey of the author of the referenced event.
    public var pubkey: String? {
        guard tag.otherParameters.count >= 3 else {
            return nil
        }

        // Validate that the pubkey is valid before returning it.
        return PublicKey(hex: tag.otherParameters[2])?.hex
    }

    /// Initializes an event tag from a ``Tag``.
    /// `nil` is returned if the tag is not an event tag.
    public init?(tag: Tag) {
        guard tag.name == TagName.event.rawValue else {
            return nil
        }

        self.tag = tag
    }

    /// Initializes an event tag.
    /// - Parameters:
    ///   - eventId: The id of the event being referenced.
    ///   - relayURL: The URL of a recommended relay associated with the reference.
    ///   - marker: The marker indicating the type of event tag.
    public init(eventId: String, relayURL: URL? = nil, marker: EventTagMarker? = nil, pubkey: String? = nil) throws {
        let validatedRelayURL: URL?
        if let relayURL {
            validatedRelayURL = try RelayURLValidator.shared.validateRelayURL(relayURL)
        } else {
            validatedRelayURL = nil
        }

        if let pubkey, PublicKey(hex: pubkey) == nil {
            throw EventCreatingError.invalidInput
        }

        var tagOtherParameters = [validatedRelayURL?.absoluteString ?? ""]

        if let marker {
            guard marker == .root || marker == .reply || marker == .mention else {
                throw EventTagError.invalidInput
            }
            tagOtherParameters.append(marker.rawValue)
        }

        if let pubkey {
            tagOtherParameters.append(pubkey)
        }

        tag = Tag(name: .event, value: eventId, otherParameters: tagOtherParameters)
    }
}

public protocol EventTagInterpreting: NostrEvent {}
public extension EventTagInterpreting {
    /// The event tags assigned to this ``NostrEvent``.
    var eventTags: [EventTag] {
        tags.filter { $0.name == TagName.event.rawValue }
            .compactMap { EventTag(tag: $0) }
    }
}
