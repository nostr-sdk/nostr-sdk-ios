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

    func shareableEventCoordinates(relayURLStrings: [String]? = nil, excludeAuthor: Bool = false, excludeKind: Bool = false) throws -> String {
        let validatedRelayURLStrings = try relayURLStrings?.map {
            try validateRelayURLString($0)
        }.map { $0.absoluteString }

        var metadata = Metadata(relays: validatedRelayURLStrings, identifier: "")
        if !excludeAuthor {
            metadata.pubkey = pubkey
        }
        if !excludeKind {
            metadata.kind = UInt32(kind.rawValue)
        }

        return try encodedIdentifier(with: metadata, identifierType: .address)
    }
}
