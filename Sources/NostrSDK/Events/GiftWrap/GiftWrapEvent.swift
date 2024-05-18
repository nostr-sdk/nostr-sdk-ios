//
//  GiftWrapEvent.swift
//
//
//  Created by Terry Yiu on 5/11/24.
//

import Foundation

/// An event that gift wraps a `SealEvent`.
/// The wrapped seal is always encrypted to a receiver's pubkey using a random, one-time-use private key.
/// The gift wrap event tags should include any information needed to route the event to its intended recipient,
/// including the recipient's `p` tag or [NIP-13 Proof of Work](https://github.com/nostr-protocol/nips/blob/master/13.md).
///
/// The underlying `SealEvent` or rumor should not be broadcast by themselves to relays without this gift wrap.
/// This gift wrap event should be broadcast to only the recipient's relays
///
/// See [NIP-59 - Gift Wrap](https://github.com/nostr-protocol/nips/blob/master/59.md).
public final class GiftWrapEvent: NostrEvent, NIP44v2Encrypting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970 - TimeInterval.random(in: 0...172800)), signedBy keypair: Keypair) throws {
        try super.init(kind: .seal, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Unwraps the content of the gift wrap event and decrypts it into a ``SealEvent``.
    /// - Parameters:
    ///   - privateKey: The ``PrivateKey`` to decrypt the content.
    /// - Returns: The ``SealEvent``.
    public func unwrap(privateKey: PrivateKey) throws -> SealEvent {
        guard let wrapperPublicKey = PublicKey(hex: pubkey) else {
            throw GiftWrapError.pubkeyInvalid
        }

        guard let unwrappedSeal = try? decrypt(payload: content, privateKeyA: privateKey, publicKeyB: wrapperPublicKey) else {
            throw GiftWrapError.decryptionFailed
        }

        guard let sealJSONData = unwrappedSeal.data(using: .utf8) else {
            throw GiftWrapError.utf8EncodingFailed
        }

        guard let sealEvent = try? JSONDecoder().decode(SealEvent.self, from: sealJSONData) else {
            throw GiftWrapError.jsonDecodingFailed
        }

        return sealEvent
    }

    /// Unseals the content of this seal event into a decrypted rumor.
    /// - Parameters:
    ///   - privateKey: The `PrivateKey` to decrypt the rumor.
    /// - Returns: The decrypted ``NostrEvent`` rumor, where its `signature` is `nil`.
    public func unseal(privateKey: PrivateKey) throws -> NostrEvent? {
        let sealEvent = try unwrap(privateKey: privateKey)
        return try sealEvent.unseal(privateKey: privateKey)
    }
}

public enum GiftWrapError: Error {
    case decryptionFailed
    case jsonDecodingFailed
    case keypairGenerationFailed
    case pubkeyInvalid
    case utf8EncodingFailed
}

public extension EventCreating {

    /// Creates a ``GiftWrapEvent`` that takes a rumor, an unsigned ``NostrEvent``, and seals it in a signed ``SealEvent``, and then wraps that seal encrypted in the content of the gift wrap.
    ///
    /// - Parameters:
    ///   - withRumor: a ``NostrEvent`` that is not signed.
    ///   - toRecipient: the ``PublicKey`` of the receiver of the event. This pubkey will automatically be added as a tag to the ``GiftWrapEvent``.
    ///   - tags: the list of tags to add to the ``GiftWrapEvent`` in addition to the pubkey tag from `toRecipient`. This list should include any information needed to route the event to its intended recipient, such as [NIP-13 Proof of Work](https://github.com/nostr-protocol/nips/blob/master/13.md).
    ///   - createdAt: the creation timestamp of the seal. Note that this timestamp SHOULD be tweaked to thwart time-analysis attacks. Note that some relays don't serve events dated in the future, so all timestamps SHOULD be in the past. By default, if `createdAt` is not provided, a random timestamp within 2 days in the past will be chosen.
    ///   - keypair: The real ``Keypair`` to sign the seal with. Note that a different random one-time use key is used to sign the gift wrap.
    func giftWrap(
        withRumor rumor: NostrEvent,
        toRecipient recipient: PublicKey,
        tags: [Tag] = [],
        createdAt: Int64 = Int64(Date.now.timeIntervalSince1970 - TimeInterval.random(in: 0...172800)),
        signedBy keypair: Keypair
    ) throws -> GiftWrapEvent {
        let seal = try seal(withRumor: rumor, toRecipient: recipient, signedBy: keypair)
        return try giftWrap(withSeal: seal, toRecipient: recipient, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Creates a ``GiftWrapEvent`` that takes a signed``SealEvent``, and then wraps that seal encrypted in the content of the gift wrap.
    ///
    /// - Parameters:
    ///   - withSeal: a signed ``SealEvent``.
    ///   - toRecipient: the ``PublicKey`` of the receiver of the event.
    ///   - tags: the list of tags
    ///   - createdAt: the creation timestamp of the seal. Note that this timestamp SHOULD be tweaked to thwart time-analysis attacks. Note that some relays don't serve events dated in the future, so all timestamps SHOULD be in the past. By default, if `createdAt` is not provided, a random timestamp within 2 days in the past will be chosen.
    ///   - keypair: The real ``Keypair`` to sign the seal with. Note that a different random one-time use key is used to sign the gift wrap.
    func giftWrap(
        withSeal seal: SealEvent,
        toRecipient recipient: PublicKey,
        tags: [Tag] = [],
        createdAt: Int64 = Int64(Date.now.timeIntervalSince1970 - TimeInterval.random(in: 0...172800)),
        signedBy keypair: Keypair
    ) throws -> GiftWrapEvent {
        let jsonData = try JSONEncoder().encode(seal)
        guard let stringifiedJSON = String(data: jsonData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }

        guard let randomKeypair = Keypair() else {
            throw GiftWrapError.keypairGenerationFailed
        }

        let combinedTags = [Tag(name: .pubkey, value: recipient.hex)] + tags

        let encryptedSeal = try encrypt(plaintext: stringifiedJSON, privateKeyA: randomKeypair.privateKey, publicKeyB: recipient)
        return try GiftWrapEvent(content: encryptedSeal, tags: combinedTags, createdAt: createdAt, signedBy: randomKeypair)
    }
}
