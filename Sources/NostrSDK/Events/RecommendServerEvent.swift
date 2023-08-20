//
//  RecommendServerEvent.swift
//  
//
//  Created by Bryan Montz on 7/23/23.
//

import Foundation

/// An event that contains a relay the event creator wants to recommend to its followers.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/b503f8a92b22be3037b8115fe3e644865a4fa155/01.md#basic-event-kinds)
public final class RecommendServerEvent: NostrEvent {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .recommendServer, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    public var relayURL: URL? {
        let components = URLComponents(string: content)
        guard components?.scheme == "wss" || components?.scheme == "ws" else {
            return nil
        }
        return components?.url
    }
}
