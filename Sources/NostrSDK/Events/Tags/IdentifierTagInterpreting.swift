//
//  IdentifierTagInterpreting.swift
//  
//
//  Created by Terry Yiu on 12/16/23.
//

import Foundation

public protocol IdentifierTagInterpreting: NostrEvent {}
public extension IdentifierTagInterpreting {
    /// The identifier of the event. For parameterized replaceable events, this identifier remains stable across replacements.
    /// This identifier is represented by the "d" tag, which is distinctly different from the `id` field on ``NostrEvent``.
    var identifier: String? {
        firstValueForTagName(.identifier)
    }

    /// The event coordinates that can be used to fetch this replaceable event's kind, pubkey, and identifier from a relay.
    ///
    /// - Parameters:
    ///   - relayURL: A relay URL that this replaceable event could be found.
    func identifierEventCoordinates(_ relayURL: URL? = nil) -> EventCoordinates? {
        guard let identifier, let publicKey = PublicKey(hex: pubkey) else {
            return nil
        }

        return EventCoordinates(kind: kind, pubkey: publicKey, identifier: identifier, relayURL: relayURL)
    }
}
