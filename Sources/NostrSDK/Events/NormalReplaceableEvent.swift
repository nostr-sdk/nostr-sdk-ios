//
//  NormalReplaceableEvent.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

public protocol NormalReplaceableEvent: ReplaceableEvent {}
public extension NormalReplaceableEvent {
    func replaceableEventCoordinates(relayURL: URL? = nil) -> EventCoordinates? {
        guard kind.isNormalReplaceable, let publicKey = PublicKey(hex: pubkey) else {
            return nil
        }

        return try? EventCoordinates(kind: kind, pubkey: publicKey, relayURL: relayURL)
    }

    func naddr(relayURLStrings: [String]? = nil, includeAuthor: Bool = true, includeKind: Bool = true) throws -> String {
        try naddr(relayURLStrings: relayURLStrings, includeAuthor: includeAuthor, includeKind: includeKind, identifier: "")
    }

    func shareableEventCoordinates(relayURLStrings: [String]? = nil, includeAuthor: Bool = true, includeKind: Bool = true) throws -> String {
        try naddr(relayURLStrings: relayURLStrings, includeAuthor: includeAuthor, includeKind: includeKind)
    }
}

@available(*, deprecated, renamed: "NormalReplaceableEvent")
public typealias NonParameterizedReplaceableEvent = NormalReplaceableEvent
