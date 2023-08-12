//
//  DirectMessageEvent.swift
//  
//
//  Created by Joel Klabo on 8/10/23.
//

import Foundation

/// An event that contains an encrypted message.
///
/// > Note: [NIP-04 Specification](https://github.com/nostr-protocol/nips/blob/master/04.md)
public final class DirectMessageEvent: NostrEvent, DirectMessageEncrypting {

    public func decryptedContent(using privateKey: PrivateKey) throws -> String {
        let recipient = tags.first { tag in
            tag.name == .pubkey
        }

        guard let recipientPublicKeyHex = recipient?.value, let recipientPublicKey = PublicKey(hex: recipientPublicKeyHex) else {
            throw DirectMessageEncryptingError.pubkeyInvalid
        }

        return try decrypt(encryptedContent: content, privateKey: privateKey, publicKey: recipientPublicKey)
    }
}
