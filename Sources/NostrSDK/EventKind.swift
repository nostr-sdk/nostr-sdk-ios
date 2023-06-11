//
//  EventKind.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

/// A constant defining the kind of an event.
public enum EventKind: Int, Codable {
    /// The content is set to a stringified JSON object `{name: <username>, about: <string>, picture: <url, string>}` describing the user who created the event. A relay may delete past `set_metadata` events once it gets a new one for the same pubkey.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    case setMetadata = 0
    
    /// The content is set to the plaintext content of a note (anything the user wants to say). Content that must be parsed, such as Markdown and HTML, should not be used. Clients should also not parse content as those.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    case textNote = 1
    
    /// The content is set to the URL (e.g., wss://somerelay.com) of a relay the event creator wants to recommend to its followers.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    case recommendServer = 2
    
    /// This kind of event should have a list of p tags, one for each of the followed/known profiles one is following.
    /// > Note: The `content` can be anything and should be ignored.
    ///
    /// See [NIP-02 - Contact List and Petnames](https://github.com/nostr-protocol/nips/blob/master/02.md#contact-list-and-petnames)
    case contactList = 3
    
    /// This kind of note is used to signal to followers that another event is worth reading.
    ///
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#nip-18).
    case repost = 6
}
