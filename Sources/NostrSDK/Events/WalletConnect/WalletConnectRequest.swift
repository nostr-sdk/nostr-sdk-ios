//
//  WalletConnectRequest.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

public enum WalletConnectType: String, Codable {
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
