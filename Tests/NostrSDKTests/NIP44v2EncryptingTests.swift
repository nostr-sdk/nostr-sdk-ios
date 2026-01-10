//
//  NIP44v2EncryptingTests.swift
//
//
//  Created by Terry Yiu on 3/17/24.
//

import XCTest
import CryptoKit
@testable import NostrSDK

final class NIP44v2EncryptingTests: XCTestCase, FixtureLoading, NIP44v2Encrypting {

    private lazy var vectors: NIP44Vectors = try! decodeFixture(filename: "nip44.vectors")  // swiftlint:disable:this force_try

    /// Calculate the conversation key from secret key, sec1, and public key, pub2.
    func testValidConversationKey() throws {
        let conversationKeyVectors = try XCTUnwrap(vectors.v2.valid.getConversationKey)

        try conversationKeyVectors.forEach { vector in
            let expectedConversationKey = try XCTUnwrap(vector.conversationKey)
            let privateKeyA = try XCTUnwrap(PrivateKey(hex: vector.sec1))
            let publicKeyB = try XCTUnwrap(PublicKey(hex: vector.pub2))
            let conversationKeyBytes = try conversationKey(
                privateKeyA: privateKeyA,
                publicKeyB: publicKeyB
            ).bytes
            let conversationKey = Data(conversationKeyBytes).hexString
            XCTAssertEqual(conversationKey, expectedConversationKey)
        }
    }

    /// Calculate ChaCha key, ChaCha nonce, and HMAC key from conversation key and nonce.
    func testValidMessageKeys() throws {
        let messageKeyVectors = try XCTUnwrap(vectors.v2.valid.getMessageKeys)
        let conversationKey = messageKeyVectors.conversationKey
        let conversationKeyBytes = try XCTUnwrap(conversationKey.hexDecoded?.bytes)
        let keys = messageKeyVectors.keys

        try keys.forEach { vector in
            let nonce = try XCTUnwrap(vector.nonce.hexDecoded)
            let messageKeys = try messageKeys(conversationKey: conversationKeyBytes, nonce: nonce)
            XCTAssertEqual(messageKeys.chaChaKey.hexString, vector.chaChaKey)
            XCTAssertEqual(messageKeys.chaChaNonce.hexString, vector.chaChaNonce)
            XCTAssertEqual(messageKeys.hmacKey.hexString, vector.hmacKey)
        }
    }

    /// Take unpadded length (first value), calculate padded length (second value).
    func testValidCalculatePaddedLength() throws {
        let calculatePaddedLengthVectors = try XCTUnwrap(vectors.v2.valid.calculatePaddedLength)
        try calculatePaddedLengthVectors.forEach { vector in
            XCTAssertEqual(vector.count, 2)
            let paddedLength = try calculatePaddedLength(vector[0])
            XCTAssertEqual(paddedLength, vector[1])
        }
    }

    /// Emulate real conversation with a hardcoded nonce.
    /// Calculate pub2 from sec2, verify conversation key from (sec1, pub2), encrypt, verify payload.
    /// Then calculate pub1 from sec1, verify conversation key from (sec2, pub1), decrypt, verify plaintext.
    func testValidEncryptDecrypt() throws {
        let encryptDecryptVectors = try XCTUnwrap(vectors.v2.valid.encryptDecrypt)
        try encryptDecryptVectors.forEach { vector in
            let sec1 = vector.sec1
            let sec2 = vector.sec2
            let expectedConversationKey = vector.conversationKey
            let nonce = try XCTUnwrap(vector.nonce.hexDecoded)
            let plaintext = vector.plaintext
            let payload = vector.payload

            let keypair1 = try XCTUnwrap(Keypair(hex: sec1))
            let keypair2 = try XCTUnwrap(Keypair(hex: sec2))

            // Conversation key from sec1 and pub2.
            let conversationKey1Bytes = try conversationKey(
                privateKeyA: keypair1.privateKey,
                publicKeyB: keypair2.publicKey
            ).bytes
            XCTAssertEqual(expectedConversationKey, Data(conversationKey1Bytes).hexString)

            // Verify payload.
            let ciphertext = try encrypt(
                plaintext: plaintext,
                conversationKey: conversationKey1Bytes,
                nonce: nonce
            )
            XCTAssertEqual(payload, ciphertext)

            // Conversation key from sec2 and pub1.
            let conversationKey2Bytes = try conversationKey(
                privateKeyA: keypair2.privateKey,
                publicKeyB: keypair1.publicKey
            ).bytes
            XCTAssertEqual(expectedConversationKey, Data(conversationKey2Bytes).hexString)

            // Verify that decrypted data equals the plaintext that we started off with.
            let decrypted = try decrypt(payload: payload, conversationKey: conversationKey2Bytes)
            XCTAssertEqual(decrypted, plaintext)
        }
    }

    /// Same as previous step, but instead of a full plaintext and payload, their checksum is provided.
    func testValidEncryptDecryptLongMessage() throws {
        let encryptDecryptVectors = try XCTUnwrap(vectors.v2.valid.encryptDecryptLongMessage)
        try encryptDecryptVectors.forEach { vector in
            let conversationKey = vector.conversationKey
            let conversationKeyData = try XCTUnwrap(conversationKey.hexDecoded)
            let conversationKeyBytes = Array(conversationKeyData)

            let nonce = try XCTUnwrap(vector.nonce.hexDecoded)
            let expectedPlaintextSHA256 = vector.plaintextSHA256

            let plaintext = String(repeating: vector.pattern, count: vector.repeatCount)
            let plaintextData = try XCTUnwrap(plaintext.data(using: .utf8))
            let plaintextSHA256 = plaintextData.sha256

            XCTAssertEqual(plaintextSHA256.hexString, expectedPlaintextSHA256)

            let payloadSHA256 = vector.payloadSHA256

            let ciphertext = try encrypt(
                plaintext: plaintext,
                conversationKey: conversationKeyBytes,
                nonce: nonce
            )
            let ciphertextData = try XCTUnwrap(ciphertext.data(using: .utf8))
            let ciphertextSHA256 = ciphertextData.sha256.hexString
            XCTAssertEqual(ciphertextSHA256, payloadSHA256)

            let decrypted = try decrypt(payload: ciphertext, conversationKey: conversationKeyBytes)
            XCTAssertEqual(decrypted, plaintext)
        }
    }

    /// Emulate real conversation with only the public encrypt and decrypt functions,
    /// where the nonce used for encryption is a cryptographically secure pseudorandom generated series of bytes.
    func testValidEncryptDecryptRandomNonce() throws {
        let encryptDecryptVectors = try XCTUnwrap(vectors.v2.valid.encryptDecrypt)
        try encryptDecryptVectors.forEach { vector in
            let sec1 = vector.sec1
            let sec2 = vector.sec2
            let plaintext = vector.plaintext

            let keypair1 = try XCTUnwrap(Keypair(hex: sec1))
            let keypair2 = try XCTUnwrap(Keypair(hex: sec2))

            // Encrypt plaintext with user A's private key and user B's public key.
            let ciphertext = try encrypt(
                plaintext: plaintext,
                privateKeyA: keypair1.privateKey,
                publicKeyB: keypair2.publicKey
            )

            // Decrypt ciphertext with user B's private key and user A's public key.
            let decrypted = try decrypt(payload: ciphertext, privateKeyA: keypair2.privateKey, publicKeyB: keypair1.publicKey)
            XCTAssertEqual(decrypted, plaintext)
        }
    }

    /// Encrypting a plaintext message that is not at a minimum of 1 byte and maximum of 65535 bytes must throw an error.
    func testInvalidEncryptMessageLengths() throws {
        let encryptMessageLengthsVectors = try XCTUnwrap(vectors.v2.invalid.encryptMessageLengths)
        try encryptMessageLengthsVectors.forEach { length in
            let randomBytes = Data.randomBytes(count: 32)
            XCTAssertThrowsError(try encrypt(plaintext: String(repeating: "a", count: length), conversationKey: randomBytes))
        }
    }

    /// Calculating conversation key must throw an error.
    func testInvalidConversationKey() throws {
        let conversationKeyVectors = try XCTUnwrap(vectors.v2.invalid.getConversationKey)

        try conversationKeyVectors.forEach { vector in
            let privateKeyA = try XCTUnwrap(PrivateKey(hex: vector.sec1))
            let publicKeyB = try XCTUnwrap(PublicKey(hex: vector.pub2))
            XCTAssertThrowsError(try conversationKey(privateKeyA: privateKeyA, publicKeyB: publicKeyB), vector.note ?? "")
        }
    }

    /// Decrypting message content must throw an error
    func testInvalidDecrypt() throws {
        let decryptVectors = try XCTUnwrap(vectors.v2.invalid.decrypt)
        try decryptVectors.forEach { vector in
            let conversationKey = Array(try XCTUnwrap(vector.conversationKey.hexDecoded))
            let payload = vector.payload
            XCTAssertThrowsError(try decrypt(payload: payload, conversationKey: conversationKey), vector.note)
        }
    }

}
