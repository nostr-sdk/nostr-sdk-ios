//
//  WalletConnectInfoEvent.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/9/24.
//

import Foundation

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
