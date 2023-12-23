//
//  ReplaceableEvent.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

/// Replaceable events are ones where only the latest event MUST be stored by relays, older versions MAY be discarded.
public protocol ReplaceableEvent: NostrEvent {
    /// The event coordinates that can be used to query this replaceable event's kind, pubkey, and identifier (if it is parameterized) from any relay.
    /// The event coordinates are stable across versions.
    var replaceableEventCoordinates: EventCoordinates? { get }

    /// The event coordinates that can be used to query this replaceable event's kind, pubkey, and identifier (if it is parameterized) from a specific relay.
    /// The event coordinates are stable across versions.
    ///
    /// - Parameters:
    ///   - relayURL: A relay URL that this replaceable event could be found.
    func replaceableEventCoordinates(relayURL: URL) -> EventCoordinates?
}
