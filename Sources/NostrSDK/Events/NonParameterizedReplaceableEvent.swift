//
//  NonParameterizedReplaceableEvent.swift
//
//
//  Created by Terry Yiu on 12/23/23.
//

import Foundation

public protocol NonParameterizedReplaceableEvent: ReplaceableEvent {}
public extension NonParameterizedReplaceableEvent {
    var replaceableEventCoordinates: EventCoordinates? {
        guard kind.isNonParameterizedReplaceable, let publicKey = PublicKey(hex: pubkey) else {
            return nil
        }

        do {
            return try EventCoordinates(kind: kind, pubkey: publicKey)
        } catch {
            return nil
        }
    }

    func replaceableEventCoordinates(relayURL: URL) -> EventCoordinates? {
        guard kind.isNonParameterizedReplaceable, let publicKey = PublicKey(hex: pubkey) else {
            return nil
        }

        do {
            return try EventCoordinates(kind: kind, pubkey: publicKey, relayURL: relayURL)
        } catch {
            return nil
        }
    }
}
