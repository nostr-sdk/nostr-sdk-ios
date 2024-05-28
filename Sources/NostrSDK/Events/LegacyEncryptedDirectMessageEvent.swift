//
//  LegacyEncryptedDirectMessageEvent.swift
//
//
//  Created by Joel Klabo on 8/10/23.
//

import Foundation

/// An event that contains an encrypted message.
///
/// > Note: [NIP-04 - Encrypted Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md)
/// > Warning: Deprecated in favor of [NIP-17 - Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md).
@available(*, deprecated, message: "Deprecated in favor of NIP-17 - Private Direct Messages.")
public final class LegacyEncryptedDirectMessageEvent: NostrEvent, LegacyDirectMessageEncrypting {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .legacyEncryptedDirectMessage, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Returns decrypted content from Event given a `privateKey`
    public func decryptedContent(using privateKey: PrivateKey) throws -> String {
        let recipient = tags.first { tag in
            tag.name == TagName.pubkey.rawValue
        }

        guard let recipientPublicKeyHex = recipient?.value, let recipientPublicKey = PublicKey(hex: recipientPublicKeyHex) else {
            throw LegacyDirectMessageEncryptingError.pubkeyInvalid
        }

        return try legacyDecrypt(encryptedContent: content, privateKey: privateKey, publicKey: recipientPublicKey)
    }
}

public extension EventCreating {

    /// Creates a ``LegacyEncryptedDirectMessageEvent`` (kind 4) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - toRecipient: The PublicKey of the recipient.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``LegacyEncryptedDirectMessageEvent``.
    ///
    /// See [NIP-04 - Encrypted Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md)
    /// > Warning: Deprecated in favor of [NIP-17 - Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md).
    @available(*, deprecated, message: "Deprecated in favor of NIP-17 - Private Direct Messages.")
    func legacyEncryptedDirectMessage(withContent content: String, toRecipient pubkey: PublicKey, signedBy keypair: Keypair) throws -> LegacyEncryptedDirectMessageEvent {
        guard let encryptedMessage = try? legacyEncrypt(content: content, privateKey: keypair.privateKey, publicKey: pubkey) else {
            throw EventCreatingError.invalidInput
        }
        
        let recipientTag = Tag.pubkey(pubkey.hex)
        return try LegacyEncryptedDirectMessageEvent(content: encryptedMessage, tags: [recipientTag], signedBy: keypair)
    }
}
