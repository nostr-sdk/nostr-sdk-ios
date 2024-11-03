//
//  ExpirationTag.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/3/24.
//

import Foundation

/// Interprets the expiration tag.
///
/// See [NIP-40 - Expiration Timestamp](https://github.com/nostr-protocol/nips/blob/master/40.md).
public protocol ExpirationTagInterpreting: NostrEvent {}
public extension ExpirationTagInterpreting {
    /// Unix timestamp at which the message SHOULD be considered expired (by relays and clients) and SHOULD be deleted by relays.
    var expiration: Int64? {
        if let expiration = firstValueForTagName(.expiration) {
            return Int64(expiration)
        } else {
            return nil
        }
    }

    /// Whether the message SHOULD be considered expired (by relays and clients) and SHOULD be deleted by relays.
    var isExpired: Bool {
        if let expiration {
            return Int64(Date.now.timeIntervalSince1970) >= expiration
        } else {
            return false
        }
    }
}

/// Builder that adds an expiration to an event.
///
/// See [NIP-40 - Expiration Timestamp](https://github.com/nostr-protocol/nips/blob/master/40.md).
public protocol ExpirationTagBuilding: NostrEventBuilding {}
public extension ExpirationTagBuilding {
    /// Specifies a unix timestamp at which the message SHOULD be considered expired (by relays and clients) and SHOULD be deleted by relays.
    @discardableResult
    func expiration(_ expiration: Int64) -> Self {
        appendTags(Tag(name: .expiration, value: String(expiration)))
    }
}
