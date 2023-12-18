//
//  GenericRepostEvent.swift
//  
//
//  Created by Bryan Montz on 8/3/23.
//

import Foundation

/// A generic repost event (kind 16) can include any kind of event inside other than kind 1.
/// > Note: Generic reposts SHOULD contain a `k` tag with the stringified kind number of the reposted event as its value.
/// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#generic-reposts).
public class GenericRepostEvent: NostrEvent, RelayURLValidating {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: Self.kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    class var kind: EventKind {
        .genericRepost
    }
    
    /// The pubkey of the reposted event.
    var repostedEventPubkey: String? {
        firstValueForTagName(.pubkey)
    }
    
    /// The note that is being reposted.
    var repostedEvent: NostrEvent? {
        guard let jsonData = content.data(using: .utf8),
              let note: NostrEvent = try? JSONDecoder().decode(NostrEvent.self, from: jsonData) else {
            return nil
        }
        return note
    }
    
    /// The id of the event that is being reposted.
    var repostedEventId: String? {
        firstValueForTagName(.event)
    }
    
    /// The relay URL at which to fetch the reposted event.
    var repostedEventRelayURL: URL? {
        guard let eventTag = tags.first(where: { $0.name == TagName.event.rawValue }),
              let relayString = eventTag.otherParameters.first else {
            return nil
        }

        return try? validateRelayURLString(relayString)
    }
}
