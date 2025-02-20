//
//  PrivateEventRelayListEvent.swift
//  NostrSDK
//
//  Created by Terry Yiu on 2/2/25.
//

import Foundation

public final class PrivateEventRelayListEvent: NostrEvent, NIP44v2Encrypting, NormalReplaceableEvent {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    /// Returns the validated decrypted relay URLs.
    /// - Parameters:
    ///   - keypair: The ``Keypair`` to use to decrypt the relay URLs.
    /// - Returns: The decrypted list of ``URL``s for relays.
    public func relayURLs(decryptedWith keypair: Keypair) throws -> [URL] {
        guard let decryptedContent = try? decrypt(payload: content, privateKeyA: keypair.privateKey, publicKeyB: keypair.publicKey) else {
            throw PrivateEventRelayListEventError.decryptionFailed
        }

        guard let jsonData = decryptedContent.data(using: .utf8) else {
            throw PrivateEventRelayListEventError.utf8EncodingFailed
        }

        guard let decryptedRelayURLStrings = try? JSONDecoder().decode([String].self, from: jsonData) else {
            throw PrivateEventRelayListEventError.jsonDecodingFailed
        }

        return try decryptedRelayURLStrings.compactMap { try validateRelayURLString($0) }
    }
}

public enum PrivateEventRelayListEventError: Error {
    case decryptionFailed
    case encryptionFailed
    case jsonDecodingFailed
    case utf8EncodingFailed
}

public extension PrivateEventRelayListEvent {
    /// Builder of a ``PrivateEventRelayListEvent``.
    final class Builder: NostrEvent.Builder<PrivateEventRelayListEvent>, NIP44v2Encrypting, RelayURLValidating {
        public init() {
            super.init(kind: .privateEventRelayList)
        }

        /// Sets the user's preferred relay URLs to store private events.
        /// - Parameters:
        ///   - relayURLs: The user's preferred relay ``URL``s to store private events.
        ///   - keypair: The ``Keypair`` to use to encrypt the relay ``URL``s.
        @discardableResult
        public final func relayURLs(_ relayURLs: [URL], encryptedWith keypair: Keypair) throws -> Self {
            let validatedRelayURLs = try relayURLs.map { try validateRelayURL($0) }

            let encryptedRelayURLStrings = try encryptedRelayURLs(validatedRelayURLs, encryptedWith: keypair)

            return content(encryptedRelayURLStrings)
        }

        /// Sets the user's preferred relay URL strings to store private events.
        /// - Parameters:
        ///   - relayURLs: The user's preferred relay URL strings to store private events.
        ///   - keypair: The ``Keypair`` to use to encrypt the relay ``URL``s.
        @discardableResult
        public final func relayURLStrings(_ relayURLStrings: [String], encryptedWith keypair: Keypair) throws -> Self {
            let validatedRelayURLs = try relayURLStrings.map { try validateRelayURLString($0) }

            let encryptedRelayURLStrings = try encryptedRelayURLs(validatedRelayURLs, encryptedWith: keypair)

            return content(encryptedRelayURLStrings)
        }

        /// Sets the user's preferred validated relay URLs to store private events.
        /// - Parameters:
        ///   - validatedRelayURLs: The user's validated preferred relay ``URL``s to store private events.
        ///   - keypair: The ``Keypair`` to use to encrypt the relay ``URL``s.
        private func encryptedRelayURLs(_ validatedRelayURLs: [URL], encryptedWith keypair: Keypair) throws -> String {
            let validatedRelayURLStrings = validatedRelayURLs.map { $0.absoluteString }
            let jsonData = try JSONEncoder().encode(validatedRelayURLStrings)
            guard let stringifiedJSON = String(data: jsonData, encoding: .utf8) else {
                throw PrivateEventRelayListEventError.utf8EncodingFailed
            }

            guard let encryptedRelayURLStrings = try? encrypt(plaintext: stringifiedJSON, privateKeyA: keypair.privateKey, publicKeyB: keypair.publicKey) else {
                throw PrivateEventRelayListEventError.encryptionFailed
            }

            return encryptedRelayURLStrings
        }
    }
}
