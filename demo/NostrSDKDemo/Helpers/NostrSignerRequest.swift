//
//  NostrSignerRequest.swift
//  YetiActionExtension
//
//  Created by Terry Yiu on 2/3/25.
//

import Foundation

struct NostrSignerRequests: Codable {
    let requests: [NostrSignerRequest]
    let source: String?

    enum CodingKeys: String, CodingKey {
        case requests = "nostrsigner"
        case source
    }
}

struct NostrSignerRequest: Codable {
    let type: NostrSignerCommand?
    let returnType: NostrSignerReturnType?
    let payload: String?

    enum CodingKeys: String, CodingKey {
        case type
        case returnType = "return_type"
        case payload
    }
}

enum NostrSignerCommand: String, Codable, CaseIterable {
    case getPublicKey = "get_public_key"
    case signEvent = "sign_event"
    case nip04Encrypt = "nip04_encrypt"
    case nip44Encrypt = "nip44_encrypt"
    case nip04Decrypt = "nip04_decrypt"
    case nip44Decrypt = "nip44_decrypt"
    case getRelays = "get_relays"
    case decryptZapEvent = "decrypt_zap_event"
}

enum NostrSignerReturnType: String, Codable {
    case signature
    case event
}
