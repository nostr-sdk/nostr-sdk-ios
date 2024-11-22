//
//  WalletConnectInfoEvent.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/9/24.
//

import Foundation

enum WalletConnectErrorCode: String, Codable, Error {
    /// The client is sending commands too fast. It should retry in a few seconds.
    case rateLimited = "RATE_LIMITED"
    /// The command is not known or is intentionally not implemented.
    case notImplemented = "NOT_IMPLEMENTED"
    /// The wallet does not have enough funds to cover a fee reserve or the payment amount.
    case insufficentBallance = "INSUFFICIENT_BALANCE"
    /// The wallet has exceeded its spending quota.
    case quotaExceeded = "QUOTA_EXCEEDED"
    /// This public key is not allowed to do this operation.
    case restricted = "RESTRICTED"
    /// This public key has no wallet connected.
    case unauthorizes = "UNAUTHORIZED"
    /// An internal error.
    case `internal` = "INTERNAL"
    /// Other error.
    case other = "OTHER"
}

public struct WalletConnectError: Codable {
    let code: WalletConnectErrorCode
    let message: String
}

enum WalletConnectType: String, Codable {
    case payInvoice
    case multiPayInvoice
    case payKeysend
    case multiPayKeysend
    case makeInvoice
    case lookupInvoice
    case listTransactions
    case getBalance
    case getInfo
    case notifications // TODO: DOES THIS BELONG HERE?
}

public struct WalletConnectRequest: Codable {
    let method: WalletConnectType
    var params: [String: Parameter]
    
    enum Parameter: Codable {
        case string(String)
        case int(Int)
        case bool(Bool)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let int = try? container.decode(Int.self) {
                self = .int(int)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
            } else {
                throw DecodingError.typeMismatch(
                    Parameter.self,
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown type in params")
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .int(let value):
                try container.encode(value)
            case .bool(let value):
                try container.encode(value)
            }
        }
    }
}

public struct WalletConnectInfo: Codable {
    /// indicates the structure of the result field
    let resultType: WalletConnectType
    /// object, non-null in case of error/
    let error: WalletConnectError?
    /// result, object. null in case of error.
//    let result: WalletConnectResult?
}

/// A special event with kind 3, meaning "follow list" is defined as having a list of p tags, one for each of the followed/known profiles one is following.
///
/// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md)
public final class WalletConnectInfoEvent: NostrEvent, NonParameterizedReplaceableEvent {
    
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
}

public final class WalletConnectRequestEvent: NostrEvent, NonParameterizedReplaceableEvent {
    
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
}

public final class WalletConnectResponseEvent: NostrEvent, NonParameterizedReplaceableEvent {
    
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
}
