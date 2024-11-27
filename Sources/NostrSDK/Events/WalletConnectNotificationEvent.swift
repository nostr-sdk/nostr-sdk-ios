//
//  WalletConnectNotificationEvent.swift
//  NostrSDK
//
//  Created by Thomas Rademaker on 11/27/24.
//

import Foundation

/// Event sent by wallet services to notify clients of wallet events like received payments.
/// See [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md).
public final class WalletConnectNotificationEvent: NostrEvent {
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
    
    public init(clientPubkey: String, notificationType: String, notification: [String: Any], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        let tags = [Tag(name: "p", value: clientPubkey)]
        
        let notificationContent: [String: Any] = [
            "notification_type": notificationType,
            "notification": notification
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: notificationContent)
        let contentString = String(data: jsonData, encoding: .utf8) ?? ""
        
        try super.init(
            kind: .walletConnectNotification,
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
    
    /// The notification content including type and data
    public var notificationContent: (type: String, data: [String: Any])? {
        guard let data = content.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["notification_type"] as? String,
              let notification = json["notification"] as? [String: Any] else {
            return nil
        }
        return (type, notification)
    }
}

public extension EventCreating {
    /// Creates a ``WalletConnectNotificationEvent`` (kind 23196) for wallet notifications.
    /// - Parameters:
    ///   - clientPubkey: The public key of the client to notify
    ///   - notificationType: The type of notification (e.g. "payment_received")
    ///   - notification: The notification data
    ///   - keypair: The Keypair to sign with
    /// - Returns: The signed ``WalletConnectNotificationEvent``
    func walletConnectNotification(clientPubkey: String, notificationType: String, notification: [String: Any], signedBy keypair: Keypair) throws -> WalletConnectNotificationEvent {
        try WalletConnectNotificationEvent(clientPubkey: clientPubkey, notificationType: notificationType, notification: notification, signedBy: keypair)
    }
}
