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
        return try SetMetadataEvent(content: metadataAsString, signedBy: keypair)
    }
    
    /// Creates a ``TextNoteEvent`` (kind 1) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - subject: A subject for the text note.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TextNoteEvent``.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func textNote(withContent content: String, subject: String? = nil, signedBy keypair: Keypair) throws -> TextNoteEvent {
        let tags: [Tag]
        if let subject {
            tags = [Tag(name: .subject, value: subject)]
        } else {
            tags = []
        }
        return try TextNoteEvent(content: content, tags: tags, signedBy: keypair)
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
        return try RecommendServerEvent(content: relayURL.absoluteString, signedBy: keypair)
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
        return try DirectMessageEvent(content: encryptedMessage, tags: [recipientTag], signedBy: keypair)
    }
    
    /// Creates a ``DeletionEvent`` (kind 5) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - events: The events the signer would like to request deletion for.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``DeletionEvent``.
    ///
    /// > Important: Events can only be deleted using the same keypair that was used to create them.
    /// See [NIP-09 Specification](https://github.com/nostr-protocol/nips/blob/master/09.md)
    func delete(events: [NostrEvent], reason: String? = nil, signedBy keypair: Keypair) throws -> DeletionEvent {
        // Verify that the events being deleted were created with the same keypair.
        let creatorValidatedEvents = events.filter { $0.pubkey == keypair.publicKey.hex }
        
        guard !creatorValidatedEvents.isEmpty else {
            throw EventCreatingError.invalidInput
        }
        
        let tags = creatorValidatedEvents.map { Tag(name: .event, value: $0.id) }
        return try DeletionEvent(content: reason ?? "", tags: tags, signedBy: keypair)
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

        return try ReactionEvent(content: content, tags: tags, signedBy: keypair)
    }
    
    /// Creates a ``ReportEvent`` (kind 1984) which reports a user for spam, illegal and explicit content.
    /// - Parameters:
    ///   - pubkey: The pubkey being reported.
    ///   - reportType: The type (or reason) for the reporting. See ``ReportType``.
    ///   - additionalInformation: Additional information submitted by the entity reporting the content.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReportEvent``.
    func reportUser(withPublicKey pubkey: PublicKey, reportType: ReportType, additionalInformation: String = "", signedBy keypair: Keypair) throws -> ReportEvent {
        try ReportEvent(content: additionalInformation,
                        tags: [Tag(name: .pubkey, value: pubkey.hex, otherParameters: [reportType.rawValue])],
                        signedBy: keypair)
    }
    
    /// Creates a ``ReportEvent`` (kind 1984) which reports other notes for spam, illegal and explicit content.
    /// - Parameters:
    ///   - note: The note being reported.
    ///   - reportType: The type (or reason) for the reporting. See ``ReportType``.
    ///   - additionalInformation: Additional information submitted by the entity reporting the content.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReportEvent``.
    func reportNote(_ note: NostrEvent, reportType: ReportType, additionalInformation: String = "", signedBy keypair: Keypair) throws -> ReportEvent {
        guard reportType != .impersonation else {
            throw EventCreatingError.invalidInput
        }
        let tags = [
            Tag(name: .event, value: note.id, otherParameters: [reportType.rawValue]),
            Tag(name: .pubkey, value: note.pubkey)
        ]
        return try ReportEvent(content: additionalInformation, tags: tags, signedBy: keypair)
    }
}
