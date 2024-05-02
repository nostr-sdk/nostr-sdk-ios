//
//  AuthenticationEvent.swift
//
//
//  Created by Terry Yiu on 5/1/24.
//

import Foundation

/// An event that provides a way for clients to authenticate to relays.
/// This kind is not meant to be published or queried.
///
/// See [NIP-42](https://github.com/nostr-protocol/nips/blob/master/42.md).
public final class AuthenticationEvent: NostrEvent, RelayProviding, RelayURLValidating {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .authentication, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// The relay URL where this event authenticates to it.
    public var relayURL: URL? {
        guard let relayURLString = firstValueForRawTagName("relay") else {
            return nil
        }

        return try? validateRelayURLString(relayURLString)
    }

    /// The challenge string as received from the relay.
    public var challenge: String? {
        firstValueForRawTagName("challenge")
    }
}

public extension EventCreating {

    func authenticate(relayURL: URL, challenge: String, signedBy keypair: Keypair) throws -> AuthenticationEvent {
        let validatedRelayURL = try RelayURLValidator.shared.validateRelayURL(relayURL)

        let tags: [Tag] = [
            Tag(name: "relay", value: validatedRelayURL.absoluteString),
            Tag(name: "challenge", value: challenge)
        ]

        return try AuthenticationEvent(content: "", tags: tags, signedBy: keypair)
    }
}
