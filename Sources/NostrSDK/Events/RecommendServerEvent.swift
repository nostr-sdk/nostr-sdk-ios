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
final class RecommendServerEvent: NostrEvent {
    var relayURL: URL? {
        let components = URLComponents(string: content)
        guard components?.scheme == "wss" || components?.scheme == "ws" else {
            return nil
        }
        return components?.url
    }
}
