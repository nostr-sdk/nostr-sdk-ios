//
//  WalletConnectInfo.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

public struct WalletConnectInfo: Codable {
    /// indicates the structure of the result field
    let resultType: WalletConnectType
    /// object, non-null in case of error/
    let error: WalletConnectError?
    /// result, object. null in case of error.
    let result: WalletTransaction?
}
