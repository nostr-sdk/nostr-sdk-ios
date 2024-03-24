//
//  NIP44v2Encrypting.swift
//
//
//  Created by Terry Yiu on 3/16/24.
//

import Foundation
import Clibsodium
import CryptoKit
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

internal struct DecodedPayload {
    let nonce: Data
    let ciphertext: Data
    let mac: Data
}

internal struct MessageKeys {
    let chaChaKey: Data
    let chaChaNonce: Data
    let hmacKey: Data
}

/// Introduces a data format for keypair-based encryption.
/// See [NIP-44 - Encrypted Payloads](https://github.com/nostr-protocol/nips/blob/master/44.md).
public protocol NIP44v2Encrypting {}
public extension NIP44v2Encrypting {

    /// Calculates length of the padded byte array.
    internal func calculatePaddedLength(_ unpaddedLength: Int) throws -> Int {
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
    internal func pad(_ plaintext: String) throws -> Data {
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
    internal func unpad(_ padded: Data) throws -> String {
        guard padded.count >= 2 else {
            throw NIP44v2EncryptingError.paddingInvalid
        }

        let unpaddedLength = (Int(padded[0]) << 8) | Int(padded[1])

        guard 2+unpaddedLength <= padded.count else {
            throw NIP44v2EncryptingError.paddingInvalid
        }

        let unpadded = padded.bytes[2..<2+unpaddedLength]
        let paddedLength = try calculatePaddedLength(unpaddedLength)

        guard unpaddedLength > 0,
              unpadded.count == unpaddedLength,
              padded.count == 2 + paddedLength,
              let result = String(data: Data(unpadded), encoding: .utf8) else {
            throw NIP44v2EncryptingError.paddingInvalid
        }

        return result
    }

    internal func decodePayload(_ payload: String) throws -> DecodedPayload {
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

    internal func hmacAad(key: Data, message: Data, aad: Data) throws -> Data {
        guard aad.count == 32 else {
            throw NIP44v2EncryptingError.aadLengthInvalid(aad.count)
        }

        let combined = aad + message

        return Data(HMAC<CryptoKit.SHA256>.authenticationCode(for: combined, using: SymmetricKey(data: key)).bytes)
    }

    private func preparePublicKeyBytes(from publicKey: PublicKey) throws -> [UInt8] {
        guard let publicKeyBytes = publicKey.hex.hexDecoded?.bytes else {
            throw NIP44v2EncryptingError.publicKeyInvalid
        }

        let prefix = Data([2])
        let prefixBytes = prefix.bytes

        return prefixBytes + publicKeyBytes
    }

    private func parsePublicKey(from bytes: [UInt8]) throws -> secp256k1_pubkey {
        var recipientPublicKey = secp256k1_pubkey()
        guard secp256k1_ec_pubkey_parse(secp256k1.Context.rawRepresentation, &recipientPublicKey, bytes, bytes.count) == 1 else {
            throw NIP44v2EncryptingError.publicKeyInvalid
        }
        return recipientPublicKey
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
    internal func conversationKey(senderPrivateKey: PrivateKey, recipientPublicKey: PublicKey) throws -> ContiguousBytes {
        guard let privateKeyBytes = senderPrivateKey.hex.hexDecoded?.bytes else {
            throw NIP44v2EncryptingError.privateKeyInvalid
        }
        let publicKeyBytes = try preparePublicKeyBytes(from: recipientPublicKey)
        let recipientPublicKey = try parsePublicKey(from: publicKeyBytes)
        let sharedSecret = try computeSharedSecret(using: recipientPublicKey, and: privateKeyBytes)

        return HKDF<CryptoKit.SHA256>.extract(inputKeyMaterial: SymmetricKey(data: sharedSecret), salt: Data("nip44-v2".utf8))
    }

    /// Calculates unique per-message key.
    internal func messageKeys(conversationKey: ContiguousBytes, nonce: Data) throws -> MessageKeys {
        guard conversationKey.bytes.count == 32 else {
            throw NIP44v2EncryptingError.conversationKeyLengthInvalid(conversationKey.bytes.count)
        }

        guard nonce.count == 32 else {
            throw NIP44v2EncryptingError.nonceLengthInvalid(nonce.count)
        }

        let keys = HKDF<CryptoKit.SHA256>.expand(pseudoRandomKey: conversationKey, info: nonce, outputByteCount: 76)
        let keysBytes = keys.bytes

        let chaChaKey = Data(keysBytes[0..<32])
        let chaChaNonce = Data(keysBytes[32..<44])
        let hmacKey = Data(keysBytes[44..<76])

        return MessageKeys(chaChaKey: chaChaKey, chaChaNonce: chaChaNonce, hmacKey: hmacKey)
    }

    func encrypt(content: String, senderPrivateKey: PrivateKey, recipientPublicKey: PublicKey) throws -> String {
        let conversationKey = try conversationKey(senderPrivateKey: senderPrivateKey, recipientPublicKey: recipientPublicKey)

        return try encrypt(plaintext: content, conversationKey: conversationKey)
    }

    internal func encrypt(plaintext: String, conversationKey: ContiguousBytes, nonce: Data? = nil) throws -> String {
        let nonceData: Data
        if let nonce {
            nonceData = nonce
        } else {
            // Fetches randomness from CSPRNG.
            nonceData = Data.randomBytes(count: 32)
        }

        let messageKeys = try messageKeys(conversationKey: conversationKey, nonce: nonceData)
        let padded = try pad(plaintext)
        let paddedBytes = padded.bytes

        let chaChaKey = messageKeys.chaChaKey.bytes
        let chaChaNonce = messageKeys.chaChaNonce.bytes

        var ciphertext = Data(count: padded.count)
        try ciphertext.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
            guard let ciphertextPointer = pointer.bindMemory(to: UInt8.self).baseAddress else {
                throw NIP44v2EncryptingError.chaCha20EncryptionFailed
            }

            crypto_stream_chacha20_ietf_xor(ciphertextPointer, paddedBytes, UInt64(padded.count), chaChaNonce, chaChaKey)
        }

        let mac = try hmacAad(key: messageKeys.hmacKey, message: ciphertext, aad: nonceData)

        let data = Data([2]) + nonceData + ciphertext + mac
        return data.base64EncodedString()
    }

    func decrypt(payload: String, conversationKey: ContiguousBytes) throws -> String {
        let decodedPayload = try decodePayload(payload)
        let nonce = decodedPayload.nonce
        let ciphertext = decodedPayload.ciphertext
        let ciphertextBytes = ciphertext.bytes
        let mac = decodedPayload.mac

        let messageKeys = try messageKeys(conversationKey: conversationKey, nonce: nonce)

        let calculatedMac = try hmacAad(key: messageKeys.hmacKey, message: ciphertext, aad: nonce)

        guard calculatedMac == mac else {
            throw NIP44v2EncryptingError.macInvalid
        }

        let chaChaNonce = messageKeys.chaChaNonce.bytes
        let chaChaKey = messageKeys.chaChaKey.bytes

        let ciphertextLength = ciphertext.count
        var paddedPlaintext = Data(count: ciphertextLength)

        try paddedPlaintext.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
            guard let paddedPlaintextPointer = pointer.bindMemory(to: UInt8.self).baseAddress else {
                throw NIP44v2EncryptingError.chaCha20DecryptionFailed
            }

            crypto_stream_chacha20_ietf_xor(paddedPlaintextPointer, ciphertextBytes, UInt64(ciphertextLength), chaChaNonce, chaChaKey)
        }

        return try unpad(paddedPlaintext)
    }
}
