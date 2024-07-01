//
//  NonParameterizedReplaceableEvent.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

public protocol NonParameterizedReplaceableEvent: ReplaceableEvent {}
public extension NonParameterizedReplaceableEvent {
    func replaceableEventCoordinates(relayURL: URL? = nil) -> EventCoordinates? {
        guard kind.isNonParameterizedReplaceable, let publicKey = PublicKey(hex: pubkey) else {
            return nil
        }

        return try? EventCoordinates(kind: kind, pubkey: publicKey, relayURL: relayURL)
    }

    func shareableEventCoordinates(relayURLStrings: [String]? = nil, includeAuthor: Bool = true, includeKind: Bool = true) throws -> String {
        try shareableEventCoordinates(relayURLStrings: relayURLStrings, includeAuthor: includeAuthor, includeKind: includeKind, identifier: "")
    }
}
