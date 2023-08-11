//
//  DirectMessageEncrypting.swift
//  
//
//  Created by Honk on 8/10/23.
//

import Foundation
import secp256k1
import CommonCrypto
import CryptoKit

public enum DirectMessageEncryptingError: Error {
    case pubkeyParsing
    case sharedSecretCreation
    case encryptionError
}

public protocol DirectMessageEncrypting {}
public extension DirectMessageEncrypting {

    func getSharedSecret(sender keypair: Keypair, recipient pubkey: PublicKey) throws -> [UInt8] {
        let senderPrivateKeyBytes = keypair.privateKey.dataRepresentation.bytes
        var recipientPublicKeyBytes = pubkey.dataRepresentation.bytes

        recipientPublicKeyBytes.insert(2, at: 0)

        var recipientPublicKey = secp256k1_pubkey()
        var sharedSecret = [UInt8](repeating: 0, count: 32)

        var ok = secp256k1_ec_pubkey_parse(secp256k1.Context.rawRepresentation,
                                           &recipientPublicKey,
                                           recipientPublicKeyBytes,
                                           recipientPublicKeyBytes.count) != 0

        if !ok {
            throw DirectMessageEncryptingError.pubkeyParsing
        }

        ok = secp256k1_ecdh(secp256k1.Context.rawRepresentation,
                            &sharedSecret,
                            &recipientPublicKey,
                            senderPrivateKeyBytes,
                            {(output,x32,_,_) in
                                memcpy(output, x32, 32)
                                return 1
                            },
                            nil) != 0

        if !ok {
            throw DirectMessageEncryptingError.sharedSecretCreation
        }

        return sharedSecret
    }

    func encode(content: String, sharedSecret: [UInt8]) throws -> String {
        let iv = randomBytes(count: 16).bytes
        let utf8Content = Data(content.utf8).bytes
        guard let encryptedMessage = AESEncrypt(data: utf8Content, iv: sharedSecret, shared_sec: sharedSecret) else {
            throw DirectMessageEncryptingError.encryptionError
        }

        return encodeDMBase64(content: encryptedMessage.bytes, iv: iv)
    }

    private func AESDecrypt(data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
        return AESOperation(operation: CCOperation(kCCDecrypt), data: data, iv: iv, shared_sec: shared_sec)
    }

    private func AESEncrypt(data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
        return AESOperation(operation: CCOperation(kCCEncrypt), data: data, iv: iv, shared_sec: shared_sec)
    }

    private func encodeDMBase64(content: [UInt8], iv: [UInt8]) -> String {
        let contentBase64 = Data(content).base64EncodedString()
        let ivBase64 = Data(iv).base64EncodedString()
        return contentBase64 + "?iv=" + ivBase64
    }

    private func AESOperation(operation: CCOperation, data: [UInt8], iv: [UInt8], shared_sec: [UInt8]) -> Data? {
        let data_len = data.count
        let bsize = kCCBlockSizeAES128
        let len = Int(data_len) + bsize
        var decrypted_data = [UInt8](repeating: 0, count: len)

        let key_length = size_t(kCCKeySizeAES256)
        if shared_sec.count != key_length {
            assert(false, "unexpected shared_sec len: \(shared_sec.count) != 32")
            return nil
        }

        let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)

        var num_bytes_decrypted :size_t = 0

        let status = CCCrypt(operation,  /*op:*/
                             algorithm,  /*alg:*/
                             options,    /*options:*/
                             shared_sec, /*key:*/
                             key_length, /*keyLength:*/
                             iv,         /*iv:*/
                             data,       /*dataIn:*/
                             data_len, /*dataInLength:*/
                             &decrypted_data,/*dataOut:*/
                             len,/*dataOutAvailable:*/
                             &num_bytes_decrypted/*dataOutMoved:*/
        )

        if UInt32(status) != UInt32(kCCSuccess) {
            return nil
        }

        return Data(bytes: decrypted_data, count: num_bytes_decrypted)
    }

    private func randomBytes(count: Int) -> Data {
        var bytes = [Int8](repeating: 0, count: count)
        guard
            SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess
        else {
            fatalError("can't copy secure random data")
        }
        return Data(bytes: bytes, count: count)
    }
}