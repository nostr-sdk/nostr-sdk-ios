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

public protocol EventCreating: DirectMessageEncrypting {}
public extension EventCreating {
    
    /// Creates a ``SetMetadataEvent`` (kind 0) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - userMetadata: The metadata to set.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``SetMetadataEvent``.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func setMetadataEvent(withUserMetadata userMetadata: UserMetadata, signedBy keypair: Keypair) throws -> SetMetadataEvent {
        let metadataAsData = try JSONEncoder().encode(userMetadata)
        guard let metadataAsString = String(data: metadataAsData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }
        return try SetMetadataEvent(kind: .setMetadata, content: metadataAsString, signedBy: keypair)
    }
    
    /// Creates a ``TextNoteEvent`` (kind 1) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TextNoteEvent``.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func textNote(withContent content: String, signedBy keypair: Keypair) throws -> TextNoteEvent {
        try TextNoteEvent(kind: .textNote, content: content, signedBy: keypair)
    }
    
    /// Creates a ``RecommendServerEvent`` (kind 2) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - relayURL: The URL of the relay, which must be a websocket URL.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``RecommendServerEvent``.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func recommendServerEvent(withRelayURL relayURL: URL, signedBy keypair: Keypair) throws -> RecommendServerEvent {
        let components = URLComponents(url: relayURL, resolvingAgainstBaseURL: false)
        guard components?.scheme == "wss" || components?.scheme == "ws" else {
            throw EventCreatingError.invalidInput
        }
        return try RecommendServerEvent(kind: .recommendServer, content: relayURL.absoluteString, signedBy: keypair)
    }
    
    /// Creates a ``ContactListEvent`` (kind 3) following the provided pubkeys and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - pubkeys: The pubkeys of followed/known profiles to add to the contact list, in hex format.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ContactListEvent``.
    ///
    /// Use this initializer if you do not intend to include petnames as part of the contact list.
    ///
    /// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md#contact-list-and-petnames)
    func contactList(withPubkeys pubkeys: [String], signedBy keypair: Keypair) throws -> ContactListEvent {
        try contactList(withPubkeyTags: pubkeys.map { Tag(name: .pubkey, value: $0) },
                        signedBy: keypair)
    }
    
    /// Creates a ``ContactListEvent`` (kind 3) with the provided pubkey tags and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - pubkeyTags: The pubkey tags of followed/known profiles to add to the contact list, which may include petnames.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ContactListEvent``.
    ///
    /// Use this initializer if you intend to include petnames as part of the contact list.
    ///
    /// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md#contact-list-and-petnames)
    func contactList(withPubkeyTags pubkeyTags: [Tag], signedBy keypair: Keypair) throws -> ContactListEvent {
        guard !pubkeyTags.contains(where: { $0.name != .pubkey }) else {
            throw EventCreatingError.invalidInput
        }
        return try ContactListEvent(tags: pubkeyTags,
                                    signedBy: keypair)
    }

    /// Creates a ``DirectMessageEvent`` (kind 4) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - toRecipient: The PublicKey of the recipient.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``DirectMessageEvent``.
    ///
    /// See [NIP-04 - Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md)
    func directMessage(withContent content: String, toRecipient pubkey: PublicKey, signedBy keypair: Keypair) throws -> DirectMessageEvent {
        guard let encryptedMessage = try? encrypt(content: content, privateKey: keypair.privateKey, publicKey: pubkey) else {
            throw EventCreatingError.invalidInput
        }

        let recipientTag = Tag(name: .pubkey, value: pubkey.hex)
        return try DirectMessageEvent(kind: .directMessage, content: encryptedMessage, tags: [recipientTag], signedBy: keypair)
    }
    
    /// Creates a ``TextNoteRepostEvent`` (kind 6) or ``GenericRepostEvent`` (kind 16) based on the kind of the event being reposted and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - event: The event to repost.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TextNoteRepostEvent`` or ``GenericRepostEvent``.
    ///
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#reposts).
    func repost(event: NostrEvent, signedBy keypair: Keypair) throws -> GenericRepostEvent {
        let jsonData = try JSONEncoder().encode(event)
        guard let stringifiedJSON = String(data: jsonData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }
        var tags = [
            Tag(name: .event, value: event.id),
            Tag(name: .pubkey, value: event.pubkey)
        ]
        if event.kind == .textNote {
            return try TextNoteRepostEvent(content: stringifiedJSON, tags: tags, signedBy: keypair)
        } else {
            tags.append(Tag(name: .kind, value: String(event.kind.rawValue)))
            
            return try GenericRepostEvent(content: stringifiedJSON, tags: tags, signedBy: keypair)
        }
    }
    
    /// Creates a ``ReactionEvent`` (kind 7) in response to a different ``NostrEvent`` and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the reaction.
    ///   - reactedEvent: The NostrEvent being reacted to.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReactionEvent``.
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
