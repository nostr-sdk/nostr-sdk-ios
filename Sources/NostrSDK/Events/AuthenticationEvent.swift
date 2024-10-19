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
public final class AuthenticationEvent: NostrEvent, RelayProviding {
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

    @available(*, deprecated, message: "Deprecated in favor of AuthenticationEvent.Builder.")
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .authentication, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// The relay URL this event authenticates to.
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

    @available(*, deprecated, message: "Deprecated in favor of AuthenticationEvent.Builder.")
    func authenticate(relayURL: URL, challenge: String, signedBy keypair: Keypair) throws -> AuthenticationEvent {
        try AuthenticationEvent.Builder()
            .relayURL(relayURL)
            .challenge(challenge)
            .build(signedBy: keypair)
    }
}

public extension AuthenticationEvent {
    /// Builder of a ``AuthenticationEvent``.
    final class Builder: NostrEvent.Builder<AuthenticationEvent> {
        public init() {
            super.init(kind: .authentication)
        }

        /// The relay URL this event authenticates to.
        @discardableResult
        public final func relayURL(_ relayURL: URL) throws -> Self {
            let validatedRelayURL = try RelayURLValidator.shared.validateRelayURL(relayURL)
            return appendTags(Tag(name: "relay", value: validatedRelayURL.absoluteString))
        }

        /// The challenge string as received from the relay.
        @discardableResult
        public final func challenge(_ challenge: String) throws -> Self {
            appendTags(Tag(name: "challenge", value: challenge))
        }
    }
}
