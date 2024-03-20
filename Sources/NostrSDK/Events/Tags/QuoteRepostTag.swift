//
//  QuoteRepostTag.swift
//
//
//  Created by Terry Yiu on 2/25/24.
//

import Foundation

/// Represents an "q" tag which is a quote repost tag.
///
/// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#quote-reposts) for a description of "q" tags.
public struct QuoteRepostTag: RelayProviding, RelayURLValidating, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag
    }

    /// The ``Tag`` that represents this quote repost tag.
    public let tag: Tag

    /// The id of the event being quote reposted.
    public var quotedEventId: String {
        tag.value
    }

    /// The URL of a recommended relay associated with the event being quote reposted.
    public var relayURL: URL? {
        guard let relayString = tag.otherParameters.first, !relayString.isEmpty else {
            return nil
        }

        return try? validateRelayURLString(relayString)
    }

    /// Initializes an event tag from a ``Tag``.
    /// `nil` is returned if the tag is not a quote repost tag.
    public init?(tag: Tag) {
        guard tag.name == TagName.event.rawValue else {
            return nil
        }

        self.tag = tag
    }

    /// Initializes a quote repost tag.
    /// - Parameters:
    ///   - eventId: The id of the event being quote reposted.
    ///   - relayURL: The URL of a recommended relay associated with the quote reposted event.
    public init(eventId: String, relayURL: URL? = nil) throws {
        let validatedRelayURL: URL?
        if let relayURL {
            validatedRelayURL = try RelayURLValidator.shared.validateRelayURL(relayURL)
        } else {
            validatedRelayURL = nil
        }

        tag = Tag(name: .event, value: eventId, otherParameters: [validatedRelayURL?.absoluteString ?? ""])
    }
}
