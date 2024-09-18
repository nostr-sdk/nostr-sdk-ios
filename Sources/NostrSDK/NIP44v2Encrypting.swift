//
//  NIP44v2Encrypting.swift
//
//
//  Created by Terry Yiu on 3/16/24.
//

import Foundation
import CryptoKit
import CryptoSwift
import secp256k1

public enum NIP44v2EncryptingError: Error {
    case aadLengthInvalid(Int)
    case base64EncodingFailed
    case chaCha20DecryptionFailed
    case chaCha20EncryptionFailed
    case conversationKeyLengthInvalid(Int)
    case dataSizeInvalid(Int)
    case macInvalid
    case nonceLengthInvalid(Int)
    case paddingInvalid
    case payloadSizeInvalid(Int)
    case plaintextLengthInvalid(Int)
    case privateKeyInvalid
    case publicKeyInvalid
    case sharedSecretComputationFailed
    case unknownVersion(Int? = nil)
    case unpaddedLengthInvalid(Int)
    case utf8EncodingFailed
}

struct DecodedPayload {
    let nonce: Data
    let ciphertext: Data
    let mac: Data
}

struct MessageKeys {
    let chaChaKey: Data
    let chaChaNonce: Data
    let hmacKey: Data
}

/// Introduces a data format for keypair-based encryption.
/// See [NIP-44 - Encrypted Payloads](https://github.com/nostr-protocol/nips/blob/master/44.md).
public protocol NIP44v2Encrypting {}

public extension NIP44v2Encrypting {

    /// Produces a `String` containing `plaintext` that has been encrypted using the `privateKey` of user A and the `publicKey`  of user B.
    ///
    /// The result is non-deterministic because a cryptographically secure pseudorandom generated nonce is used each time,
    /// but can be decrypted deterministically with a call to ``NIP44v2Encrypting/decrypt(payload:privateKeyA:publicKeyB:)``,
    /// where user A and user B are interchangeable.
    ///
    /// This function can `throw` an error from ``NIP44v2EncryptingError`` if it fails to encrypt the plaintext.
    ///
    /// - Parameters:
    ///   - plaintext: The plaintext to encrypt.
    ///   - privateKeyA: The private key of user A.
    ///   - publicKeyB: The public key of user B.
    /// - Returns: The encrypted ciphertext.
    func encrypt(plaintext: String, privateKeyA: PrivateKey, publicKeyB: PublicKey) throws -> String {
        let conversationKey = try conversationKey(privateKeyA: privateKeyA, publicKeyB: publicKeyB)

        return try encrypt(plaintext: plaintext, conversationKey: conversationKey)
    }

    /// Produces a `String` containing `payload` that has been decrypted using the `privateKey` of user A and the `publicKey` of user B,
    /// and the result is identical to if the `privateKey` of user B and `publicKey` of user A were used to decrypt `payload` instead.
    ///
    /// Any ciphertext returned from the call to ``NIP44v2Encrypting/encrypt(plaintext:privateKeyA:publicKeyB:)``
    /// can be decrypted, where user A and B are interchangeable.
    ///
    /// This function can `throw` an error from ``NIP44v2EncryptingError`` if it fails to decrypt the payload.
    ///
    /// - Parameters:
    ///   - payload: The payload to decrypt.
    ///   - privateKeyA: The private key of user A.
    ///   - publicKeyB: The public key of user B.
    /// - Returns: The decrypted plaintext message.
    func decrypt(payload: String, privateKeyA: PrivateKey, publicKeyB: PublicKey) throws -> String {
        let conversationKey = try conversationKey(privateKeyA: privateKeyA, publicKeyB: publicKeyB)

        return try decrypt(payload: payload, conversationKey: conversationKey)
    }
}

extension NIP44v2Encrypting {

    /// Calculates length of the padded byte array.
    func calculatePaddedLength(_ unpaddedLength: Int) throws -> Int {
        guard unpaddedLength > 0 else {
            throw NIP44v2EncryptingError.unpaddedLengthInvalid(unpaddedLength)
        }
        if unpaddedLength <= 32 {
            return 32
        }

        let nextPower = 1 << (Int(floor(log2(Double(unpaddedLength) - 1))) + 1)
        let chunk: Int

        if nextPower <= 256 {
            chunk = 32
        } else {
            chunk = nextPower / 8
        }

        return chunk * (Int(floor((Double(unpaddedLength) - 1) / Double(chunk))) + 1)
    }

    /// Converts unpadded plaintext to padded bytes.
    func pad(_ plaintext: String) throws -> Data {
        guard let unpadded = plaintext.data(using: .utf8) else {
            throw NIP44v2EncryptingError.utf8EncodingFailed
        }

        let unpaddedLength = unpadded.count

        guard 1...65535 ~= unpaddedLength else {
            throw NIP44v2EncryptingError.plaintextLengthInvalid(unpaddedLength)
        }

        var prefix = Data(count: 2)
        prefix.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
            ptr.storeBytes(of: UInt16(unpaddedLength).bigEndian, as: UInt16.self)
        }

        let suffix = Data(count: try calculatePaddedLength(unpaddedLength) - unpaddedLength)

        return prefix + unpadded + suffix
    }

    /// Converts padded bytes to unpadded plaintext.
    func unpad(_ padded: Data) throws -> String {
        guard padded.count >= 2 else {
            throw NIP44v2EncryptingError.paddingInvalid
        }

        let unpaddedLength = (Int(padded[0]) << 8) | Int(padded[1])

        guard 2+unpaddedLength <= padded.count else {
            throw NIP44v2EncryptingError.paddingInvalid
        }

        let unpadded = toBytes(from: padded)[2..<2+unpaddedLength]
        let paddedLength = try calculatePaddedLength(unpaddedLength)

        guard unpaddedLength > 0,
              unpadded.count == unpaddedLength,
              padded.count == 2 + paddedLength,
              let result = String(data: Data(unpadded), encoding: .utf8) else {
            throw NIP44v2EncryptingError.paddingInvalid
        }

        return result
    }

    func decodePayload(_ payload: String) throws -> DecodedPayload {
        let payloadLength = payload.count

        guard payloadLength > 0 && payload.first != "#" else {
            throw NIP44v2EncryptingError.unknownVersion()
        }
        guard 132...87472 ~= payloadLength else {
            throw NIP44v2EncryptingError.payloadSizeInvalid(payloadLength)
        }

        guard let data = Data(base64Encoded: payload) else {
            throw NIP44v2EncryptingError.base64EncodingFailed
        }

        let dataLength = data.count

        guard 99...65603 ~= dataLength else {
            throw NIP44v2EncryptingError.dataSizeInvalid(dataLength)
        }

        guard let version = data.first else {
            throw NIP44v2EncryptingError.unknownVersion()
        }

        guard version == 2 else {
            throw NIP44v2EncryptingError.unknownVersion(Int(version))
        }

        let nonce = data[data.index(data.startIndex, offsetBy: 1)..<data.index(data.startIndex, offsetBy: 33)]
        let ciphertext = data[data.index(data.startIndex, offsetBy: 33)..<data.index(data.startIndex, offsetBy: dataLength - 32)]
        let mac = data[data.index(data.startIndex, offsetBy: dataLength - 32)..<data.index(data.startIndex, offsetBy: dataLength)]

        return DecodedPayload(nonce: nonce, ciphertext: ciphertext, mac: mac)
    }

    func hmacAad(key: Data, message: Data, aad: Data) throws -> Data {
        guard aad.count == 32 else {
            throw NIP44v2EncryptingError.aadLengthInvalid(aad.count)
        }

        let combined = aad + message

        return Data(CryptoKit.HMAC<CryptoKit.SHA256>.authenticationCode(for: combined, using: SymmetricKey(data: key)))
    }

    private func toBytes(from data: Data) -> [UInt8] {
        data.withUnsafeBytes { bytesPointer in Array(bytesPointer) }
    }

    private func preparePublicKeyBytes(from publicKey: PublicKey) throws -> [UInt8] {
        guard let publicKeyHexDecoded = publicKey.hex.hexDecoded else {
            throw NIP44v2EncryptingError.publicKeyInvalid
        }
        let publicKeyBytes = toBytes(from: publicKeyHexDecoded)

        let prefix = Data([2])
        let prefixBytes = toBytes(from: prefix)

        return prefixBytes + publicKeyBytes
    }

    private func parsePublicKey(from bytes: [UInt8]) throws -> secp256k1_pubkey {
        var publicKey = secp256k1_pubkey()
        guard secp256k1_ec_pubkey_parse(secp256k1.Context.rawRepresentation, &publicKey, bytes, bytes.count) == 1 else {
            throw NIP44v2EncryptingError.publicKeyInvalid
        }
        return publicKey
    }

    private func computeSharedSecret(using publicKey: secp256k1_pubkey, and privateKeyBytes: [UInt8]) throws -> [UInt8] {
        var sharedSecret = [UInt8](repeating: 0, count: 32)
        var mutablePublicKey = publicKey

        // Multiplication of point B by scalar a (a ⋅ B), defined in [BIP340](https://github.com/bitcoin/bips/blob/e918b50731397872ad2922a1b08a5a4cd1d6d546/bip-0340.mediawiki).
        // The operation produces a shared point, and we encode the shared point's 32-byte x coordinate, using method bytes(P) from BIP340.
        // Private and public keys must be validated as per BIP340: pubkey must be a valid, on-curve point, and private key must be a scalar in range [1, secp256k1_order - 1]
        guard secp256k1_ecdh(secp256k1.Context.rawRepresentation, &sharedSecret, &mutablePublicKey, privateKeyBytes, { (output, x32, _, _) in
            memcpy(output, x32, 32)
            return 1
        }, nil) != 0 else {
            throw NIP44v2EncryptingError.sharedSecretComputationFailed
        }
        return sharedSecret
    }

    /// Calculates long-term key between users A and B.
    /// The conversation key of A's private key and B's public key is equal to the conversation key of B's private key and A's public key.
    func conversationKey(privateKeyA: PrivateKey, publicKeyB: PublicKey) throws -> ContiguousBytes {
        guard let privateKeyAHexDecoded = privateKeyA.hex.hexDecoded else {
            throw NIP44v2EncryptingError.privateKeyInvalid
        }
        let privateKeyABytes = toBytes(from: privateKeyAHexDecoded)
        let publicKeyBBytes = try preparePublicKeyBytes(from: publicKeyB)
        let parsedPublicKeyB = try parsePublicKey(from: publicKeyBBytes)
        let sharedSecret = try computeSharedSecret(using: parsedPublicKeyB, and: privateKeyABytes)

        return CryptoKit.HKDF<CryptoKit.SHA256>.extract(inputKeyMaterial: SymmetricKey(data: sharedSecret), salt: Data("nip44-v2".utf8))
    }

    /// Calculates unique per-message key.
    func messageKeys(conversationKey: ContiguousBytes, nonce: Data) throws -> MessageKeys {
        let conversationKeyByteCount = conversationKey.bytes.count
        guard conversationKeyByteCount == 32 else {
            throw NIP44v2EncryptingError.conversationKeyLengthInvalid(conversationKeyByteCount)
        }

        guard nonce.count == 32 else {
            throw NIP44v2EncryptingError.nonceLengthInvalid(nonce.count)
        }

        let keys = CryptoKit.HKDF<CryptoKit.SHA256>.expand(pseudoRandomKey: conversationKey, info: nonce, outputByteCount: 76)
        let keysBytes = keys.bytes

        let chaChaKey = Data(keysBytes[0..<32])
        let chaChaNonce = Data(keysBytes[32..<44])
        let hmacKey = Data(keysBytes[44..<76])

        return MessageKeys(chaChaKey: chaChaKey, chaChaNonce: chaChaNonce, hmacKey: hmacKey)
    }

    func encrypt(plaintext: String, conversationKey: ContiguousBytes, nonce: Data? = nil) throws -> String {
        let nonceData: Data
        if let nonce {
            nonceData = nonce
        } else {
            // Fetches randomness from CSPRNG.
            nonceData = Data.randomBytes(count: 32)
        }

        let messageKeys = try messageKeys(conversationKey: conversationKey, nonce: nonceData)
        let padded = try pad(plaintext)
        let paddedBytes = toBytes(from: padded)

        let chaChaKey = toBytes(from: messageKeys.chaChaKey)
        let chaChaNonce = toBytes(from: messageKeys.chaChaNonce)

        let ciphertext = try ChaCha20(key: chaChaKey, iv: chaChaNonce).encrypt(paddedBytes)
        let ciphertextData = Data(ciphertext)

        let mac = try hmacAad(key: messageKeys.hmacKey, message: ciphertextData, aad: nonceData)

        let data = Data([2]) + nonceData + ciphertextData + mac
        return data.base64EncodedString()
    }

    func decrypt(payload: String, conversationKey: ContiguousBytes) throws -> String {
        let decodedPayload = try decodePayload(payload)
        let nonce = decodedPayload.nonce
        let ciphertext = decodedPayload.ciphertext
        let ciphertextBytes = toBytes(from: ciphertext)
        let mac = decodedPayload.mac

        let messageKeys = try messageKeys(conversationKey: conversationKey, nonce: nonce)

        let calculatedMac = try hmacAad(key: messageKeys.hmacKey, message: ciphertext, aad: nonce)

        guard calculatedMac == mac else {
            throw NIP44v2EncryptingError.macInvalid
        }

        let chaChaNonce = toBytes(from: messageKeys.chaChaNonce)
        let chaChaKey = toBytes(from: messageKeys.chaChaKey)

        let paddedPlaintext = try ChaCha20(key: chaChaKey, iv: chaChaNonce).decrypt(ciphertextBytes)
        let paddedPlaintextData = Data(paddedPlaintext.bytes)

        return try unpad(paddedPlaintextData)
    }
}
