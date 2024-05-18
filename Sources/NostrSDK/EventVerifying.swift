//
//  EventVerifying.swift
//
//
//  Created by Bryan Montz on 6/23/23.
//

import Foundation

public enum EventVerifyingError: Error, CustomStringConvertible {
    case invalidId
    case unsignedEvent

    public var description: String {
        switch self {
        case .invalidId:     return "The id property did not match the calculated id."
        case .unsignedEvent: return "The event is not signed."
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
        guard let signature = event.signature else {
            throw EventVerifyingError.unsignedEvent
        }
        try verifySignature(signature, for: event.id, withPublicKey: event.pubkey)
    }
}
