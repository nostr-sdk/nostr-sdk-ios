//
//  LegacyDirectMessageEncrypting.swift
//
//
//  Created by Joel Klabo on 8/10/23.
//

import Foundation
import secp256k1
import CommonCrypto
import CryptoKit

public enum LegacyDirectMessageEncryptingError: Error {
    case pubkeyInvalid
    case unsuccessfulExponentiation
    case encryptionError
    case decryptionError
    case missingValue
}

public protocol LegacyDirectMessageEncrypting {}
public extension LegacyDirectMessageEncrypting {

    /// Produces a `String` containing `content` that has been encrypted using a sender's `privateKey` and a recipient's `publicKey`.
    /// This function can `throw` in the case of a failure to create a shared secret, a failure to successfully encrypt, or an invalid `publicKey`.
    ///
    /// - Parameters:
    ///   - content: The content to encrypt.
    ///   - privateKey: The private key of the sender.
    ///   - publicKey: The public key of the intended recipient.
    /// - Returns: Encrypted content.
    /// > Warning: Deprecated in favor of [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md) encryption and [NIP-59](https://github.com/nostr-protocol/nips/blob/master/59.md) seals and gift wraps..
    @available(*, deprecated, message: "Deprecated in favor of NIP-44 encryption and NIP-59 seals and gift wraps.")
    func legacyEncrypt(content: String, privateKey: PrivateKey, publicKey: PublicKey) throws -> String {

        let sharedSecret = try getSharedSecret(privateKey: privateKey, recipient: publicKey)
        
        let iv = Data.randomBytes(count: 16).bytes
        let utf8Content = Data(content.utf8).bytes
        guard let encryptedMessage = AESEncrypt(data: utf8Content, iv: iv, sharedSecret: sharedSecret) else {
            throw LegacyDirectMessageEncryptingError.encryptionError
        }

        return encodeDMBase64(content: encryptedMessage.bytes, iv: iv)
    }

    /// Produces a `String` containing `encryptedContent` that has been decrypted using a recipient's `privateKey` and a sender's `publicKey`.
    /// This function can `throw` in the case of a failure to create a shared secret, a failure to successfully encrypt, or an invalid `publicKey`.

    /// - Parameters:
    ///   - encryptedContent: The content to decrypt.
    ///   - privateKey: The private key of the receiver.
    ///   - publicKey: The public key of the sender.
    /// - Returns: The un-encrypted message.
    /// > Warning: Deprecated in favor of [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md) encryption and [NIP-59](https://github.com/nostr-protocol/nips/blob/master/59.md) seals and gift wraps..
    @available(*, deprecated, message: "Deprecated in favor of NIP-44 encryption and NIP-59 seals and gift wraps.")
    func legacyDecrypt(encryptedContent message: String, privateKey: PrivateKey, publicKey: PublicKey) throws -> String {
        guard let sharedSecret = try? getSharedSecret(privateKey: privateKey, recipient: publicKey) else {
            throw EventCreatingError.invalidInput
        }

        let sections = Array(message.split(separator: "?"))

        if sections.count != 2 {
            throw LegacyDirectMessageEncryptingError.decryptionError
        }

        guard let encryptedContent = sections.first,
              let encryptedContentData = Data(base64Encoded: String(encryptedContent)) else {
            throw LegacyDirectMessageEncryptingError.decryptionError
        }

        guard let ivContent = sections.last else {
            throw LegacyDirectMessageEncryptingError.decryptionError
        }

        let ivContentTrimmed = ivContent.dropFirst(3)

        guard let ivContentData = Data(base64Encoded: String(ivContentTrimmed)),
              let decryptedContentData = AESDecrypt(data: encryptedContentData.bytes, iv: ivContentData.bytes, sharedSecret: sharedSecret) else {
            throw LegacyDirectMessageEncryptingError.decryptionError
        }

        return String(decoding: decryptedContentData, as: UTF8.self)
    }

    private func getSharedSecret(privateKey: PrivateKey, recipient pubkey: PublicKey) throws -> [UInt8] {
        let privateKeyBytes = privateKey.dataRepresentation.bytes
        let publicKeyBytes = preparePublicKeyBytes(from: pubkey)

        let recipientPublicKey = try parsePublicKey(from: publicKeyBytes)
        return try computeSharedSecret(using: recipientPublicKey, and: privateKeyBytes)
    }

    private func preparePublicKeyBytes(from pubkey: PublicKey) -> [UInt8] {
        var bytes = pubkey.dataRepresentation.bytes
        bytes.insert(2, at: 0)
        return bytes
    }

    private func parsePublicKey(from bytes: [UInt8]) throws -> secp256k1_pubkey {
        var recipientPublicKey = secp256k1_pubkey()
        guard secp256k1_ec_pubkey_parse(secp256k1.Context.rawRepresentation, &recipientPublicKey, bytes, bytes.count) != 0 else {
            throw LegacyDirectMessageEncryptingError.pubkeyInvalid
        }
        return recipientPublicKey
    }

    private func computeSharedSecret(using publicKey: secp256k1_pubkey, and privateKeyBytes: [UInt8]) throws -> [UInt8] {
        var sharedSecret = [UInt8](repeating: 0, count: 32)
        var mutablePublicKey = publicKey
        guard secp256k1_ecdh(secp256k1.Context.rawRepresentation, &sharedSecret, &mutablePublicKey, privateKeyBytes, { (output, x32, _, _) in
            memcpy(output, x32, 32)
            return 1
        }, nil) != 0 else {
            throw LegacyDirectMessageEncryptingError.unsuccessfulExponentiation
        }
        return sharedSecret
    }

    private func AESDecrypt(data: [UInt8], iv: [UInt8], sharedSecret: [UInt8]) -> Data? {
        AESOperation(operation: CCOperation(kCCDecrypt), data: data, iv: iv, sharedSecret: sharedSecret)
    }

    private func AESEncrypt(data: [UInt8], iv: [UInt8], sharedSecret: [UInt8]) -> Data? {
        AESOperation(operation: CCOperation(kCCEncrypt), data: data, iv: iv, sharedSecret: sharedSecret)
    }

    private func encodeDMBase64(content: [UInt8], iv: [UInt8]) -> String {
        let contentBase64 = Data(content).base64EncodedString()
        let ivBase64 = Data(iv).base64EncodedString()
        return contentBase64 + "?iv=" + ivBase64
    }

    private func AESOperation(operation: CCOperation, data: [UInt8], iv: [UInt8], sharedSecret: [UInt8]) -> Data? {
        let dataLength = data.count
        let blockSize = kCCBlockSizeAES128
        let len = Int(dataLength) + blockSize
        var decryptedData = [UInt8](repeating: 0, count: len)

        let keyLength = size_t(kCCKeySizeAES256)
        if sharedSecret.count != keyLength {
            assert(false, "unexpected shared_sec len: \(sharedSecret.count) != 32")
            return nil
        }

        let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options: CCOptions   = UInt32(kCCOptionPKCS7Padding)

        var numberOfBytesDecrypted: size_t = 0

        let status = CCCrypt(operation,
                             algorithm,
                             options,
                             sharedSecret,
                             keyLength,
                             iv,
                             data,
                             dataLength,
                             &decryptedData,
                             len,
                             &numberOfBytesDecrypted
        )

        if UInt32(status) != UInt32(kCCSuccess) {
            return nil
        }

        return Data(bytes: decryptedData, count: numberOfBytesDecrypted)
    }
}
