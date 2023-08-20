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

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .directMessage, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Returns decrypted content from Event given a `privateKey`
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
