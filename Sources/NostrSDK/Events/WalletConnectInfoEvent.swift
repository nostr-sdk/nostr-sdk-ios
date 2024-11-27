//
//  WalletConnectInfoEvent.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/9/24.
//

import Foundation

public enum WalletConnectErrorCode: String, Codable, Error {
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

/// Transaction type for NIP-47 Wallet Connect
public struct WalletTransaction: Codable {
    public let type: String // "incoming" or "outgoing"
    public let invoice: String?
    public let description: String?
    public let descriptionHash: String?
    public let preimage: String?
    public let paymentHash: String
    public let amount: Int64
    public let feesPaid: Int64?
    public let createdAt: Int64
    public let expiresAt: Int64?
    public let settledAt: Int64?
    public let metadata: [String: WalletTransactionMetadata]?
    
    private enum CodingKeys: String, CodingKey {
        case type, invoice, description
        case descriptionHash = "description_hash"
        case preimage
        case paymentHash = "payment_hash"
        case amount
        case feesPaid = "fees_paid"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case settledAt = "settled_at"
        case metadata
    }
}

public enum WalletTransactionMetadata: Codable {
    case string(String)
    case int(Int)
    case bool(Bool)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else {
            throw DecodingError.typeMismatch(
                WalletTransactionMetadata.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown type in params")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
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

public struct WalletConnectError: Codable {
    let code: WalletConnectErrorCode
    let message: String
}

enum WalletConnectType: String, Codable {
    case payInvoice = "pay_invoice"
    case multiPayInvoice = "multi_pay_invoice"
    case payKeysend = "pay_keysend"
    case multiPayKeysend = "multi_pay_keysend"
    case makeInvoice = "make_invoice"
    case lookupInvoice = "lookup_invoice"
    case listTransactions = "list_transactions"
    case getBalance = "get_balance"
    case getInfo = "get_info"
    case notifications = "notifications"
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


/// A replaceable event published by the wallet service to indicate which capabilities it supports.
/// See [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md).
public final class WalletConnectInfoEvent: NostrEvent {
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

    public init(capabilities: [String], notifications: [String]? = nil, createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        var tags: [Tag] = []
        if let notifications = notifications {
            tags.append(Tag(name: "notifications", value: notifications.joined(separator: " ")))
        }
        
        try super.init(
            kind: .walletConnectInfo,
            content: capabilities.joined(separator: " "),
            tags: tags,
            createdAt: createdAt,
            signedBy: keypair
        )
    }
    
    /// The supported capabilities space-separated
    /// e.g. "pay_invoice get_balance notifications"
    public var capabilities: [String] {
        content.split(separator: " ").map(String.init)
    }
    
    /// The supported notification types space-separated if notifications are supported
    /// e.g. "payment_received payment_sent"
    public var notificationTypes: [String]? {
        firstValueForRawTagName("notifications")?
            .split(separator: " ")
            .map(String.init)
    }
}

public extension EventCreating {
    /// Creates a ``WalletConnectInfoEvent`` (kind 13194) which advertises wallet service capabilities.
    /// - Parameters:
    ///   - capabilities: Array of supported capabilities (e.g. ["pay_invoice", "get_balance"])
    ///   - notifications: Optional array of supported notification types
    ///   - keypair: The Keypair to sign with
    /// - Returns: The signed ``WalletConnectInfoEvent``
    func walletConnectInfo(capabilities: [String], notifications: [String]? = nil, signedBy keypair: Keypair) throws -> WalletConnectInfoEvent {
        try WalletConnectInfoEvent(capabilities: capabilities, notifications: notifications, signedBy: keypair)
    }
}
