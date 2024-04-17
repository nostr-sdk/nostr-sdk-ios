//
//  DeletionEvent.swift
//
//
//  Created by Bryan Montz on 10/29/23.
//

import Foundation

/// An event that contains one or more references to other events that the 
/// event creator would like to delete.
///
/// > Note: [NIP-09 Specification](https://github.com/nostr-protocol/nips/blob/master/09.md)
public final class DeletionEvent: NostrEvent, EventCoordinatesTagInterpreting {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .deletion, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// The reason the creator of the event gave for deleting the included events.
    public var reason: String {
        content
    }
    
    /// The event ids that the creator requests deletion for.
    public var deletedEventIds: [String] {
        allValues(forTagName: .event)
    }
}

public extension EventCreating {
    
    /// Creates a ``DeletionEvent`` (kind 5) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - events: The events the signer would like to request deletion for. Only events that match the `id` will be requested for deletion.
    ///   - replaceableEvents: The replaceable events the signer would like to request deletion for. All events that match the `replaceableEventCoordinates`, regardless of if `id` match, will be requested for deletion.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``DeletionEvent``.
    ///
    /// > Important: Events can only be deleted using the same keypair that was used to create them.
    /// See [NIP-09 Specification](https://github.com/nostr-protocol/nips/blob/master/09.md)
    func delete(events: [NostrEvent] = [], replaceableEvents: [ReplaceableEvent] = [], reason: String? = nil, signedBy keypair: Keypair) throws -> DeletionEvent {
        guard !events.isEmpty || !replaceableEvents.isEmpty else {
            throw EventCreatingError.invalidInput
        }
        
        // Verify that the events being deleted were created with the same keypair.
        let creatorValidatedEvents = events.filter { $0.pubkey == keypair.publicKey.hex }
        let creatorValidatedReplaceableEvents = replaceableEvents.filter { $0.pubkey == keypair.publicKey.hex }
        
        guard !creatorValidatedEvents.isEmpty || !creatorValidatedReplaceableEvents.isEmpty else {
            throw EventCreatingError.invalidInput
        }
        
        let tags: [Tag] = creatorValidatedEvents.map { .event($0.id) } + creatorValidatedReplaceableEvents.compactMap { $0.replaceableEventCoordinates(relayURL: nil)?.tag }
        return try DeletionEvent(content: reason ?? "", tags: tags, signedBy: keypair)
    }
}
