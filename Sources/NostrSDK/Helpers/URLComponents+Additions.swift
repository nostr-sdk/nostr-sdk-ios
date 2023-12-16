//
//  URLComponents+Additions.swift
//
//
//  Created by Terry Yiu on 12/16/23.
//

import Foundation

public extension URLComponents {
    /// Returns `true` if the `scheme` component of ``URLComponents`` is valid for a Nostr relay.
    /// Acceptable schemes include WebSocket Secure (`wss`) and WebSocket (`ws`).
    var isValidRelay: Bool {
        scheme == "wss" || scheme == "ws"
    }
}
