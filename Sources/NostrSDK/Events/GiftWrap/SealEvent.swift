//
//  SealEvent.swift
//
//
//  Created by Terry Yiu on 5/5/24.
//

import Foundation

/// An event that seals a `rumor` with the sender's private key.
/// A rumor is the same thing as an unsigned event. Any event kind can be made a rumor by removing the signature.
/// The seal is always encrypted to a receiver's pubkey but there is no p tag pointing to the receiver.
/// There is no way to know who the rumor is for without the receiver's or the sender's private key.
/// The only public information in this event is who is signing it.
///
/// This event should never be broadcasted by itself to relays.
/// It should be be wrapped in a ``GiftWrapEvent`` before broadcasting it to the recipient's relays.
///
/// See [NIP-59 - Gift Wrap](https://github.com/nostr-protocol/nips/blob/master/59.md).
public final class SealEvent: NostrEvent, NIP44v2Encrypting {
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

    /// Unseals the content of this seal event into a decrypted rumor.
    /// - Parameters:
    ///   - privateKey: The ``PrivateKey`` to decrypt the rumor.
    /// - Returns: The decrypted ``NostrEvent`` rumor, where its `signature` is `nil`.
    public func unseal(privateKey: PrivateKey) throws -> NostrEvent {
        guard let authorPublicKey = PublicKey(hex: pubkey) else {
            throw SealEventError.pubkeyInvalid
        }

        guard let unsealedRumor = try? decrypt(payload: content, privateKeyA: privateKey, publicKeyB: authorPublicKey) else {
            throw SealEventError.decryptionFailed
        }

        guard let rumorJSONData = unsealedRumor.data(using: .utf8) else {
            throw SealEventError.utf8EncodingFailed
        }

        guard let rumor = try? JSONDecoder().decode(NostrEvent.self, from: rumorJSONData) else {
            throw SealEventError.jsonDecodingFailed
        }

        return rumor
    }
}

public enum SealEventError: Error {
    case decryptionFailed
    case jsonDecodingFailed
    case pubkeyInvalid
    case sealSignedEvent
    case utf8EncodingFailed
}

public extension EventCreating {

    /// Creates a `SealEvent` that encrypts a rumor with the sender's private key and receiver's public key.
    /// There is no p tag pointing to the receiver. There is no way to know who the rumor is for without the receiver's or the sender's private key.
    /// The only public information in this event is who is signing it.
    ///
    /// - Parameters:
    ///   - withRumor: a ``NostrEvent`` that is not signed.
    ///   - toRecipient: the ``PublicKey`` of the receiver of the event.
    ///   - createdAt: the creation timestamp of the seal. Note that this timestamp SHOULD be tweaked to thwart time-analysis attacks. Note that some relays don't serve events dated in the future, so all timestamps SHOULD be in the past. By default, if `createdAt` is not provided, a random timestamp within 2 days in the past will be chosen.
    ///   - keypair: The ``Keypair`` to sign with.
    func seal(
        withRumor rumor: NostrEvent,
        toRecipient recipient: PublicKey,
        createdAt: Int64 = Int64(Date.now.timeIntervalSince1970 - TimeInterval.random(in: 0...172800)),
        signedBy keypair: Keypair
    ) throws -> SealEvent {
        guard rumor.isRumor else {
            throw SealEventError.sealSignedEvent
        }

        let jsonData = try JSONEncoder().encode(rumor)
        guard let stringifiedJSON = String(data: jsonData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }

        let encryptedRumor = try encrypt(plaintext: stringifiedJSON, privateKeyA: keypair.privateKey, publicKeyB: recipient)
        return try SealEvent(content: encryptedRumor, createdAt: createdAt, signedBy: keypair)
    }
}
