//
//  WalletConnectResponseEvent.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

import Foundation

/// Event sent by wallet services in response to request events.
/// See [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md).
public final class WalletConnectResponseEvent: NostrEvent {
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
    
    public init(clientPubkey: String, requestId: String, resultType: String, error: [String: String]? = nil, result: [String: Any]? = nil, createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        let tags = [
            Tag(name: "p", value: clientPubkey),
            Tag(name: "e", value: requestId)
        ]
        
        var responseContent: [String: Any] = ["result_type": resultType]
        responseContent["error"] = error
        responseContent["result"] = result
        
        let jsonData = try JSONSerialization.data(withJSONObject: responseContent)
        let contentString = String(data: jsonData, encoding: .utf8) ?? ""
        
        try super.init(
            kind: .walletConnectResponse,
            content: contentString,
            tags: tags,
            createdAt: createdAt,
            signedBy: keypair
        )
    }
    
    /// The client's public key
    public var clientPubkey: String? {
        firstValueForTagName(.pubkey)
    }
    
    /// The ID of the request event being responded to
    public var requestId: String? {
        firstValueForTagName(.event)
    }
    
    /// The response content including result type, error if any, and result data
    public var response: (WalletConnectResponse)? {
        guard let data = content.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let resultType = json["result_type"] as? String else {
            return nil
        }
        
        let error = json["error"] as? [String: String]
        let result = json["result"] as? [String: Any]
        
        return WalletConnectResponse(resultType: resultType, error: error, result: result)
    }
    
    public struct WalletConnectResponse {
        let resultType: String
        let error: [String : String]?
        let result: [String : Any]?
    }
}

public extension EventCreating {
    /// Creates a ``WalletConnectResponseEvent`` (kind 23195) for responding to wallet requests.
    /// - Parameters:
    ///   - clientPubkey: The public key of the requesting client
    ///   - requestId: The ID of the request event being responded to
    ///   - resultType: The type of result (matches request method)
    ///   - error: Optional error details if request failed
    ///   - result: Optional result data if request succeeded
    ///   - keypair: The Keypair to sign with
    /// - Returns: The signed ``WalletConnectResponseEvent``
    func walletConnectResponse(clientPubkey: String, requestId: String, resultType: String, error: [String: String]? = nil, result: [String: Any]? = nil, signedBy keypair: Keypair) throws -> WalletConnectResponseEvent {
        try WalletConnectResponseEvent(clientPubkey: clientPubkey, requestId: requestId, resultType: resultType, error: error, result: result, signedBy: keypair)
    }
}
