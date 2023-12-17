//
//  ReplaceableEventCoordinates.swift
//
//
//  Created by Terry Yiu on 12/16/23.
//

import Foundation

/// Coordinates to a (maybe parameterized) replaceable event.
/// See [NIP-01 Tags](https://github.com/nostr-protocol/nips/blob/master/01.md#tags).
public struct ReplaceableEventCoordinates: PubkeyProviding, RelayProviding, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag
    }

    /// The tag representation of these replaceable event coordinates.
    public let tag: Tag

    private var tagValueSplit: [Substring] {
        tag.value.split(separator: ":", omittingEmptySubsequences: false)
    }

    /// The kind integer of the referenced replaceable event.
    /// Returns `nil` if the kind integer part of the tag value is malformed.
    public var kind: EventKind? {
        guard let kindInt = Int(String(tagValueSplit[0])) else {
            return nil
        }

        return EventKind(rawValue: kindInt)
    }

    /// The pubkey that signed the referenced replaceable event.
    /// Returns `nil` if the pubkey part of the tag value is malformed.
    public var pubkey: PublicKey? {
        PublicKey(hex: String(tagValueSplit[1]))
    }

    /// The identifier of the referenced replaceable event.
    /// Returns `nil` if the returned event is not a parameterized replaceable event.
    public var identifier: String? {
        let identifierParameter = tagValueSplit[2]
        guard !identifierParameter.isEmpty else {
            return nil
        }

        return String(identifierParameter)
    }

    /// A relay in which the referenced replaceable event could be found.
    /// Returns `nil` if the relay URL is malformed.
    public var relayURL: URL? {
        guard let relayString = tag.otherParameters.first else {
            return nil
        }

        return relayString.relayURL
    }

    /// Initializes coordinates to a replaceable event from a ``Tag``.
    /// For a parameterized replaceable event, a tag value of `<kind integer>:<32-bytes lowercase hex of a pubkey>:<d tag value>` is expected.
    /// For a non-parameterized replaceable event, a tag value of `<kind integer>:<32-bytes lowercase hex of a pubkey>:` is expected.
    ///
    /// Returns `nil` if the tag is not a replaceable event tag or if the tag value does not have at least two ":" colon separators.
    ///
    /// - Parameters:
    ///   - pubkey: The public key of the participant.
    public init?(replaceableEventTag: Tag) {
        guard replaceableEventTag.name == TagName.replaceableEvent.rawValue else {
            return nil
        }

        let split = replaceableEventTag.value.split(separator: ":", omittingEmptySubsequences: false)

        guard split.count >= 3 else {
            return nil
        }

        self.tag = replaceableEventTag
    }

    /// Initializes coordinates to a replaceable event.
    /// - Parameters:
    ///   - kind: The ``EventKind`` of the referenced replaceable event.
    ///   - pubkey: The pubkey that signed the referenced replaceable event.
    ///   - identifier: The identifier of the referenced replaceable event.
    ///   - relayURL: A relay in which the referenced replaceable event could be found.
    public init?(kind: EventKind, pubkey: PublicKey, identifier: String?, relayURL: URL? = nil) {
        let otherParameters: [String]
        if let relayURL {
            guard let components = URLComponents(url: relayURL, resolvingAgainstBaseURL: false), components.isValidRelay else {
                return nil
            }

            otherParameters = [relayURL.absoluteString]
        } else {
            otherParameters = []
        }

        self.init(
            replaceableEventTag: Tag(
                name: .replaceableEvent,
                value: "\(kind.rawValue):\(pubkey.hex):\(identifier ?? "")",
                otherParameters: otherParameters
            )
        )
    }
}

public protocol ReplaceableEventCoordinatesInterpreting: NostrEvent {}
public extension ReplaceableEventCoordinatesInterpreting {
    /// The referenced replaceable event tags of the event.
    var eventCoordinates: [ReplaceableEventCoordinates] {
        tags.filter { $0.name == TagName.replaceableEvent.rawValue }
            .compactMap { ReplaceableEventCoordinates(replaceableEventTag: $0) }
    }
}
