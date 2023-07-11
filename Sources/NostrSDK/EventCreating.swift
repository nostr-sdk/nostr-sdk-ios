//
//  EventCreating.swift
//
//
//  Created by Bryan Montz on 6/25/23.
//

import Foundation

enum EventCreatingError: Error {
    case invalidInput
}

public protocol EventCreating {}
public extension EventCreating {
    
    /// Creates a set metadata event (kind 0) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - userMetadata: The metadata to set.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed set metadata event.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func setMetadataEvent(withUserMetadata userMetadata: UserMetadata, signedBy keypair: Keypair) throws -> SetMetadataEvent {
        let metadataAsData = try JSONEncoder().encode(userMetadata)
        guard let metadataAsString = String(data: metadataAsData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }
        return try SetMetadataEvent(kind: .setMetadata, content: metadataAsString, signedBy: keypair)
    }
    
    /// Creates a text note event (kind 1) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed text note event.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func textNote(withContent content: String, signedBy keypair: Keypair) throws -> TextNoteEvent {
        try TextNoteEvent(kind: .textNote, content: content, signedBy: keypair)
    }
    
    /// Creates a recommend server event (kind 2) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - relayURL: The URL of the relay, which must be a websocket URL.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed recommend server event.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func recommendServerEvent(withRelayURL relayURL: URL, signedBy keypair: Keypair) throws -> RecommendServerEvent {
        let components = URLComponents(url: relayURL, resolvingAgainstBaseURL: false)
        guard components?.scheme == "wss" || components?.scheme == "ws" else {
            throw EventCreatingError.invalidInput
        }
        return try RecommendServerEvent(kind: .recommendServer, content: relayURL.absoluteString, signedBy: keypair)
    }

    /// Creates a reaction event (kind 7) in response to a different ``NostrEvent`` and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the reaction.
    ///   - reactedEvent: The NostrEvent being reacted to.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed reaction event.
    ///
    /// See [NIP-25 - Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
    func reaction(withContent content: String, reactedEvent: NostrEvent, signedBy keypair: Keypair) throws -> ReactionEvent {
        let eventTag = Tag(name: .event, value: reactedEvent.id)
        let pubkeyTag = Tag(name: .pubkey, value: reactedEvent.pubkey)

        var tags = reactedEvent.tags.filter { $0.name == .event || $0.name == .pubkey }
        tags.append(eventTag)
        tags.append(pubkeyTag)

        return try ReactionEvent(kind: .reaction, content: content, tags: tags, signedBy: keypair)
    }
}
