//
//  AddressableEvent.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

public protocol AddressableEvent: ReplaceableEvent, MetadataCoding {}
public extension AddressableEvent {
    /// The identifier of the event. For addressable events, this identifier remains stable across replacements.
    /// This identifier is represented by the "d" tag, which is distinctly different from the `id` field on ``NostrEvent``.
    var identifier: String? {
        firstValueForTagName(.identifier)
    }

    func replaceableEventCoordinates(relayURL: URL? = nil) -> EventCoordinates? {
        guard kind.isAddressable, let identifier, let publicKey = PublicKey(hex: pubkey) else {
            return nil
        }

        return try? EventCoordinates(kind: kind, pubkey: publicKey, identifier: identifier, relayURL: relayURL)
    }

    func naddr(relayURLStrings: [String]?, includeAuthor: Bool, includeKind: Bool) throws -> String {
        try naddr(relayURLStrings: relayURLStrings, includeAuthor: includeAuthor, includeKind: includeKind, identifier: identifier ?? "")
    }

    func shareableEventCoordinates(relayURLStrings: [String]? = nil, includeAuthor: Bool = true, includeKind: Bool = true) throws -> String {
        try naddr(relayURLStrings: relayURLStrings, includeAuthor: includeAuthor, includeKind: includeKind)
    }
}

@available(*, deprecated, renamed: "AddressableEvent")
public typealias ParameterizedReplaceableEvent = AddressableEvent
