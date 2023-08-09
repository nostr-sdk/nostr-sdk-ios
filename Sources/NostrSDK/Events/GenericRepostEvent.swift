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
public class GenericRepostEvent: NostrEvent {
    /// The pubkey of the reposted event.
    var repostedEventPubkey: String? {
        tags.first(where: { $0.name == .pubkey })?.value
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
        tags.first(where: { $0.name == .event })?.value
    }
    
    /// The relay URL at which to fetch the reposted event.
    var repostedEventRelayURL: String? {
        tags.first(where: { $0.name == .event })?.otherParameters.first
    }
}
