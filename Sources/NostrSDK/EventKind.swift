//
//  EventKind.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

/// A constant defining the kind of an event.
public enum EventKind: RawRepresentable, CaseIterable, Codable, Equatable {

    public typealias RawValue = Int

    /// The content is set to a stringified JSON object `{name: <username>, about: <string>, picture: <url, string>}` describing the user who created the event. A relay may delete past `set_metadata` events once it gets a new one for the same pubkey.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    case setMetadata
    
    /// The content is set to the plaintext content of a note (anything the user wants to say). Content that must be parsed, such as Markdown and HTML, should not be used. Clients should also not parse content as those.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    case textNote
    
    /// The content is set to the URL (e.g., wss://somerelay.com) of a relay the event creator wants to recommend to its followers.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    case recommendServer
    
    /// This kind of event should have a list of p tags, one for each of the followed/known profiles one is following.
    /// > Note: The `content` can be anything and should be ignored.
    ///
    /// See [NIP-02 - Contact List and Petnames](https://github.com/nostr-protocol/nips/blob/master/02.md#contact-list-and-petnames)
    case contactList

    /// This kind of event should have a recipient pubkey tag.
    ///
    /// See [NIP-04 - Direct Messages](https://github.com/nostr-protocol/nips/blob/master/04.md)
    case directMessage
    
    /// This kind of note is used to signal to followers that another event is worth reading.
    ///
    /// > Note: The reposted event must be a kind 1 text note.
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#nip-18).
    case repost
    
    /// This kind of note is used to signal to followers that another event is worth reading.
    ///
    /// > Note: The reposted event can be any kind of event other than a kind 1 text note.
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#nip-18).
    case genericRepost

    /// Any other event kind number that isn't supported by this enum yet will be represented by `unknown` so that `NostrEvent`s of those event kinds can still be encoded and decoded.
    case unknown(RawValue)

    /// List of all event kinds except for `unknown`.
    static public let allCases: AllCases = [
        .setMetadata,
        .textNote,
        .recommendServer,
        .contactList,
        .directMessage,
        .repost,
        .genericRepost
    ]

    public init(rawValue: Int) {
        self = Self.allCases.first { $0.rawValue == rawValue }
               ?? .unknown(rawValue)
    }

    public var rawValue: RawValue {
        switch self {
        case .setMetadata: return 0
        case .textNote: return 1
        case .recommendServer: return 2
        case .contactList: return 3
        case .directMessage: return 4
        case .repost: return 6
        case .genericRepost: return 16
        case let .unknown(value): return value
        }
    }
}
