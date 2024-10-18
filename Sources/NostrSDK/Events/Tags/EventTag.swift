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

/// Interprets threaded tags on events.
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
public protocol ThreadedEventTagInterpreting: NostrEvent {}
public extension ThreadedEventTagInterpreting {
    /// The ``EventTag`` that denotes the reply event being responded to.
    /// This event tag may be the same as ``rootEventTag`` if this event is a direct reply to the root of a thread.
    /// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
    var replyEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Return the first event tag with a reply marker if it exists.
        if let reply = eventTags.first(where: { $0.marker == .reply }) {
            return reply
        }

        // A direct reply to the root of a thread should have a single marked event tag of type "root".
        if let root = eventTags.first(where: { $0.marker == .root }) {
            return root
        }

        // If there are no reply or root event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no reply event tag.
        guard eventTags.allSatisfy({ $0.marker == nil }) else {
            return nil
        }

        // Otherwise, NIP-10 states that the last event tag is the one being responded to.
        return eventTags.last
    }

    /// The ``EventTag`` that denotes the root event of the thread being responded to.
    /// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
    var rootEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Return the first event tag with a root marker if it exists.
        if let root = eventTags.first(where: { $0.marker == .root }) {
            return root
        }

        // If there are no root event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no root event tag.
        guard eventTags.allSatisfy({ $0.marker == nil }) else {
            return nil
        }

        // NIP-10 states that the first event tag is the root.
        return eventTags.first
    }

    /// The ``EventTag``s that denotes quoted or reposted events.
    /// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
    var mentionedEventTags: [EventTag] {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Only mention markers are considered mentions in the preferred spec.
        // If there is a mix of mention markers and no markers, the event tags
        // with no markers are ignored.
        let mentionedEventTags = eventTags.filter { $0.marker == .mention }

        if !mentionedEventTags.isEmpty {
            return mentionedEventTags
        }

        // If the event has any event tags with any marker, then we can make a reasonable assummption
        // that the client that created this event does not use deprecated positional event tags,
        // so there are no mentions.
        //
        // Even if there are no event tag markers, the deprecated positional event tag spec in NIP-10
        // states that there are no mentions unless there are 3 or more event tags.
        guard eventTags.allSatisfy({ $0.marker == nil }) && eventTags.count >= 3 else {
            return []
        }

        // The first event tag is the root and the last event tag is the one being replied to.
        // Everything else in between is a mention.
        return eventTags.dropFirst().dropLast()
    }
}

/// Builds tags on a threaded event.
/// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
public protocol ThreadedEventTagBuilding: NostrEventBuilding, RelayURLValidating {}
public extension ThreadedEventTagBuilding {
    /// Sets the ``ThreadedEventTagInterpreting`` event that is being replied to from this event that is being built.
    /// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
    @discardableResult
    func repliedEvent(_ repliedEvent: ThreadedEventTagInterpreting, relayURL: URL? = nil) throws -> Self {
        let validatedRelayURL: URL?
        if let relayURL {
            validatedRelayURL = try validateRelayURL(relayURL)
        } else {
            validatedRelayURL = nil
        }

        if let rootEventTag = repliedEvent.rootEventTag {
            // Maximize backwards compatibility with NIP-10 deprecated positional event tags
            // by ensuring ordering of types of event tags.

            // Root tag comes first.
            if rootEventTag.marker == .root {
                insertTags(rootEventTag.tag, at: 0)
            } else {
                // Recreate the event tag with a root marker if the one being read does not have a marker.
                let rootEventTagWithMarker = try EventTag(eventId: rootEventTag.eventId, relayURL: rootEventTag.relayURL, marker: .root, pubkey: rootEventTag.pubkey)
                insertTags(rootEventTagWithMarker.tag, at: 0)
            }

            // Reply tag comes last.
            appendTags(try EventTag(eventId: repliedEvent.id, relayURL: validatedRelayURL, marker: .reply, pubkey: repliedEvent.pubkey).tag)
        } else {
            // If the event being replied to has no root marker event tag,
            // the event being replied to is the root.
            insertTags(try EventTag(eventId: repliedEvent.id, relayURL: validatedRelayURL, marker: .root, pubkey: repliedEvent.pubkey).tag, at: 0)
        }

        // When replying to a text event E, the reply event's "p" tags should contain all of E's "p" tags as well as the "pubkey" of the event being replied to.
        // Example: Given a text event authored by a1 with "p" tags [p1, p2, p3] then the "p" tags of the reply should be [a1, p1, p2, p3] in no particular order.
        appendTags(contentsOf: repliedEvent.tags.filter { $0.name == TagName.pubkey.rawValue })

        // Add the author "p" tag if it was not already added.
        if !tags.contains(where: { $0.name == TagName.pubkey.rawValue && $0.value == repliedEvent.pubkey }) {
            if let validatedRelayURL {
                appendTags(Tag(name: .pubkey, value: repliedEvent.pubkey, otherParameters: [validatedRelayURL.absoluteString]))
            } else {
                appendTags(Tag(name: .pubkey, value: repliedEvent.pubkey))
            }
        }

        return self
    }

    /// Sets the list of events, represented by ``EventTag``, that are mentioned from this event that is being built.
    /// See [NIP-10](https://github.com/nostr-protocol/nips/blob/master/10.md).
    @discardableResult
    func mentionedEventTags(_ mentionedEventTags: [EventTag]) throws -> Self {
        guard !mentionedEventTags.isEmpty else {
            return self
        }

        guard mentionedEventTags.allSatisfy({ $0.marker == .mention }) else {
            throw EventCreatingError.invalidInput
        }

        let newTags = mentionedEventTags.map { $0.tag }
        // Mentions go in between root markers and reply markers.
        if let replyMarkerIndex = tags.firstIndex(where: { $0.otherParameters.count >= 2 &&  $0.otherParameters[1] == EventTagMarker.reply.rawValue }) {
            insertTags(contentsOf: newTags, at: replyMarkerIndex)
        } else {
            appendTags(contentsOf: newTags)
        }

        return self
    }
}
