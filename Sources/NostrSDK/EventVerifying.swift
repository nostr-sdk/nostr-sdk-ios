//
//  EventVerifying.swift
//
//
//  Created by Bryan Montz on 6/23/23.
//

import Foundation

public enum EventVerifyingError: Error, CustomStringConvertible {
    case invalidId
    
    public var description: String {
        switch self {
        case .invalidId:    return "The id property did not match the calculated id."
        }
    }
}

public protocol EventVerifying: SignatureVerifying {}
public extension EventVerifying {
    
    /// Verifies the identifier and the signature of a ``NostrEvent``
    func verifyEvent(_ event: NostrEvent) throws {
        guard event.id == event.calculatedId else {
            throw EventVerifyingError.invalidId
        }
        try verifySignature(event.signature, for: event.id, withPublicKey: event.pubkey)
    }
}
