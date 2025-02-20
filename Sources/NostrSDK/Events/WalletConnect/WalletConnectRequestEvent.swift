//
//  WalletConnectRequestEvent.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

import Foundation

/// Event sent by clients to request wallet operations like payments.
/// See [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md).
public final class WalletConnectRequestEvent: NostrEvent {
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
    
    public init(walletPubkey: String, method: String, params: [String: Any], expiration: Int64? = nil, createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        var tags: [Tag] = [Tag(name: "p", value: walletPubkey)]
        
        if let expiration {
            tags.append(Tag(name: "expiration", value: String(expiration)))
        }
        
        let requestContent: [String: Any] = [
            "method": method,
            "params": params
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestContent)
        let contentString = String(data: jsonData, encoding: .utf8) ?? ""
        
        try super.init(
            kind: .walletConnectRequest,
            content: contentString,
            tags: tags,
            createdAt: createdAt,
            signedBy: keypair
        )
    }
    
    /// The wallet service's public key
    public var walletPubkey: String? {
        firstValueForTagName(.pubkey)
    }
    
    /// Optional expiration timestamp
    public var expiration: Int64? {
        guard let expirationString = firstValueForRawTagName("expiration") else { return nil }
        return Int64(expirationString)
    }
    
    /// The request method and parameters
    public var request: (method: String, params: [String: Any])? {
        guard let data = content.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let method = json["method"] as? String,
              let params = json["params"] as? [String: Any] else {
            return nil
        }
        return (method, params)
    }
}

public extension EventCreating {
    /// Creates a ``WalletConnectRequestEvent`` (kind 23194) for requesting wallet operations.
    /// - Parameters:
    ///   - walletPubkey: The public key of the wallet service
    ///   - method: The method being requested (e.g. "pay_invoice")
    ///   - params: Parameters for the method
    ///   - expiration: Optional expiration timestamp
    ///   - keypair: The Keypair to sign with
    /// - Returns: The signed ``WalletConnectRequestEvent``
    func walletConnectRequest(walletPubkey: String, method: String, params: [String: Any], expiration: Int64? = nil, signedBy keypair: Keypair) throws -> WalletConnectRequestEvent {
        try WalletConnectRequestEvent(walletPubkey: walletPubkey, method: method, params: params, expiration: expiration, signedBy: keypair)
    }
}
