//
//  WalletTransaction.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

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
