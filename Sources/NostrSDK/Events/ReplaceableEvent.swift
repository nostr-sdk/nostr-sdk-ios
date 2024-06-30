//
//  ReplaceableEvent.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

/// Replaceable events are ones where only the latest event MUST be stored by relays, older versions MAY be discarded.
public protocol ReplaceableEvent: NostrEvent {
    /// The event coordinates that can be used to query this replaceable event's kind, pubkey, and identifier (if it is parameterized) from a relay.
    /// The event coordinates are stable across versions.
    ///
    /// - Parameters:
    ///   - relayURL: A relay URL that this replaceable event could be found.
    func replaceableEventCoordinates(relayURL: URL?) -> EventCoordinates?

    /// Gets a shareable human-interactable event coordinates for this replaceable event.
    /// The coordinates are bech32-formatted with a prefix of `nevent` using a binary-encoded list of TLV (type-length-value).
    /// The coordinates have all the information needed for this replaceable event to be found, which includes the
    /// identifier (if it is parameterized), optionally the relays, optionally the author's public key, and optionally the event kind number.
    /// - Parameters:
    ///   - relayURLStrings: The String representations of relay URLs in which the event is more likely to be found, encoded as ASCII.
    ///   - includeAuthor: Whether the author public key should be included in the identifier.
    ///   - includeKind: Whether the event kind number should be included in the identifier.
    /// - Throws: `URLError.Code.badURL`, `RelayURLError.invalidScheme`, `TLVCodingError.failedToEncode`
    ///
    /// > Note: [NIP-19 bech32-encoded entities](https://github.com/nostr-protocol/nips/blob/master/19.md)
    func shareableEventCoordinates(relayURLStrings: [String]?, includeAuthor: Bool, includeKind: Bool) throws -> String
}
