//
//  NIP44Vectors.swift
//
//
//  Created by Terry Yiu on 3/22/24.
//

import Foundation

struct NIP44Vectors: Decodable {
    let v2: NIP44VectorsV2

    private enum CodingKeys: String, CodingKey {
        case v2
    }
}

struct NIP44VectorsV2: Decodable {
    let valid: NIP44VectorsV2Valid
    let invalid: NIP44VectorsV2Invalid

    private enum CodingKeys: String, CodingKey {
        case valid
        case invalid
    }
}

struct NIP44VectorsV2Valid: Decodable {
    let getConversationKey: [NIP44VectorsV2GetConversationKey]
    let getMessageKeys: NIP44VectorsV2GetMessageKeys
    let calculatePaddedLength: [[Int]]
    let encryptDecrypt: [NIP44VectorsV2EncryptDecrypt]
    let encryptDecryptLongMessage: [NIP44VectorsV2EncryptDecryptLongMessage]

    private enum CodingKeys: String, CodingKey {
        case getConversationKey = "get_conversation_key"
        case getMessageKeys = "get_message_keys"
        case calculatePaddedLength = "calc_padded_len"
        case encryptDecrypt = "encrypt_decrypt"
        case encryptDecryptLongMessage = "encrypt_decrypt_long_msg"
    }
}

struct NIP44VectorsV2Invalid: Decodable {
    let encryptMessageLengths: [Int]
    let getConversationKey: [NIP44VectorsV2GetConversationKey]
    let decrypt: [NIP44VectorsDecrypt]

    private enum CodingKeys: String, CodingKey {
        case encryptMessageLengths = "encrypt_msg_lengths"
        case getConversationKey = "get_conversation_key"
        case decrypt
    }
}

struct NIP44VectorsDecrypt: Decodable {
    let conversationKey: String
    let nonce: String
    let plaintext: String
    let payload: String
    let note: String

    private enum CodingKeys: String, CodingKey {
        case conversationKey = "conversation_key"
        case nonce
        case plaintext
        case payload
        case note
    }
}

struct NIP44VectorsV2GetConversationKey: Decodable {
    let sec1: String
    let pub2: String
    let conversationKey: String?
    let note: String?

    private enum CodingKeys: String, CodingKey {
        case sec1
        case pub2
        case conversationKey = "conversation_key"
        case note
    }
}

struct NIP44VectorsV2GetMessageKeys: Decodable {
    let conversationKey: String
    let keys: [NIP44VectorsV2MessageKeys]

    private enum CodingKeys: String, CodingKey {
        case conversationKey = "conversation_key"
        case keys
    }
}

struct NIP44VectorsV2MessageKeys: Decodable {
    let nonce: String
    let chaChaKey: String
    let chaChaNonce: String
    let hmacKey: String

    private enum CodingKeys: String, CodingKey {
        case nonce
        case chaChaKey = "chacha_key"
        case chaChaNonce = "chacha_nonce"
        case hmacKey = "hmac_key"
    }
}

struct NIP44VectorsV2EncryptDecrypt: Decodable {
    let sec1: String
    let sec2: String
    let conversationKey: String
    let nonce: String
    let plaintext: String
    let payload: String

    private enum CodingKeys: String, CodingKey {
        case sec1
        case sec2
        case conversationKey = "conversation_key"
        case nonce
        case plaintext
        case payload
    }
}

struct NIP44VectorsV2EncryptDecryptLongMessage: Decodable {
    let conversationKey: String
    let nonce: String
    let pattern: String
    let repeatCount: Int
    let plaintextSHA256: String
    let payloadSHA256: String

    private enum CodingKeys: String, CodingKey {
        case conversationKey = "conversation_key"
        case nonce
        case pattern
        case repeatCount = "repeat"
        case plaintextSHA256 = "plaintext_sha256"
        case payloadSHA256 = "payload_sha256"
    }
}
