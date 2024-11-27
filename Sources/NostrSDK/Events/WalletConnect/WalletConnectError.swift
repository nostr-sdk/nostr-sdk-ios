//
//  WalletConnectError.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

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

public struct WalletConnectError: Codable {
    let code: WalletConnectErrorCode
    let message: String
}
