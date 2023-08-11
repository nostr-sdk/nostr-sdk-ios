//
//  DirectMessageEvent.swift
//  
//
//  Created by Joel Klabo on 8/10/23.
//

import Foundation

/// An event that contains an encrypted message
///
/// > Note: [NIP-04 Specification](https://github.com/nostr-protocol/nips/blob/master/04.md)
public final class DirectMessageEvent: NostrEvent {

    public func decryptedContent(keypair: Keypair) throws -> String {
        return content
    }
}
