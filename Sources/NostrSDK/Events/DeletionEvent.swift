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
public final class DeletionEvent: NostrEvent {
    
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
        allValues(forTagName: .event) ?? []
    }
}
