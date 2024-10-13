//
//  EventKind.swift
//  
//
//  Created by Bryan Montz on 5/22/23.
//

import Foundation

/// A constant defining the kind of an event.
public enum EventKind: RawRepresentable, CaseIterable, Codable, Equatable, Hashable {

    public typealias RawValue = Int

    /// The content is set to a stringified JSON object `{name: <username>, about: <string>, picture: <url, string>}` describing the user who created the event. A relay may delete past `metadata` events once it gets a new one for the same pubkey.
    ///
    /// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md)
    case metadata
    
    /// The content is set to the plaintext content of a note (anything the user wants to say). Content that must be parsed, such as Markdown and HTML, should not be used. Clients should also not parse content as those.
    ///
    /// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md)
    case textNote
    
    /// This kind of event should have a list of p tags, one for each of the followed/known profiles one is following.
    /// > Note: The `content` can be anything and should be ignored.
    ///
    /// See [NIP-02 - Follow List](https://github.com/nostr-protocol/nips/blob/master/02.md)
    case followList

    /// This kind of event should have a recipient pubkey tag.
    ///
    /// See [NIP-04 - Encrypted Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md)
    /// > Warning: Deprecated in favor of [NIP-17 - Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md).
    @available(*, deprecated, message: "Deprecated in favor of NIP-17 - Private Direct Messages.")
    case legacyEncryptedDirectMessage
    
    /// This kind of event indicates that the author requests that the events in the included
    /// tags should be deleted.
    /// > Note: This event can only *request* that the listed events be deleted. In reality, they
    /// may not be deleted by all clients or relays.
    ///
    /// See [NIP-09 - Event Deletion](https://github.com/nostr-protocol/nips/blob/master/09.md)
    case deletion
    
    /// This kind of note is used to signal to followers that another event is worth reading.
    ///
    /// > Note: The reposted event must be a kind 1 text note.
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#nip-18).
    case repost

    /// This kind of note is used to signal a reaction to other notes.
    ///
    /// See [NIP-25 - Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
    case reaction

    /// This kind of event seals a `rumor` with the sender's private key.
    /// A rumor is the same thing as an unsigned event. Any event kind can be made a rumor by removing the signature.
    /// The seal is always encrypted to a receiver's pubkey but there is no p tag pointing to the receiver.
    /// There is no way to know who the rumor is for without the receiver's or the sender's private key.
    /// The only public information in this event is who is signing it.
    ///
    /// See [NIP-59 - Gift Wrap](https://github.com/nostr-protocol/nips/blob/master/59.md).
    case seal

    /// This kind of event is a chat message meant for direct messaging with a chat room consisting of one or multiple pubkeys.
    ///
    /// See [NIP-17 - Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md).
    case directMessage

    /// This kind of note is used to signal to followers that another event is worth reading.
    ///
    /// > Note: The reposted event can be any kind of event other than a kind 1 text note.
    /// See [NIP-18](https://github.com/nostr-protocol/nips/blob/master/18.md#nip-18).
    case genericRepost

    /// This kind of event wraps a `seal` event.
    /// The wrapped seal is always encrypted to a receiver's pubkey using a random, one-time-use private key.
    /// The gift wrap event tags should include any information needed to route the event to its intended recipient,
    /// including the recipient's `p` tag or [NIP-13 Proof of Work](https://github.com/nostr-protocol/nips/blob/master/13.md).
    ///
    /// See [NIP-59 - Gift Wrap](https://github.com/nostr-protocol/nips/blob/master/59.md).
    case giftWrap

    /// This kind of note is used to report users or other notes for spam, illegal, and explicit content.
    ///
    /// See [NIP-56](https://github.com/nostr-protocol/nips/blob/b4cdc1a73d415c79c35655fa02f5e55cd1f2a60c/56.md#nip-56).
    case report
    
    /// This kind of event contains a list of things the user does not want to see, such as pubkeys, hashtags, words, and event ids (threads).
    ///
    /// See [NIP-51](https://github.com/nostr-protocol/nips/blob/master/51.md#standard-lists)
    case muteList

    /// This kind of replaceable event advertises preferred relays for discovering a user's content and receiving fresh content from others.
    ///
    /// See [NIP-65 - Relay List Metadata](https://github.com/nostr-protocol/nips/blob/master/65.md)
    case relayListMetadata

    /// This kind of event contains an uncategorized, "global" list of things a user wants to save.
    ///
    /// See [NIP-51](https://github.com/nostr-protocol/nips/blob/master/51.md#standard-lists)
    case bookmarksList

    /// This kind of event provides a way for clients to authenticate to relays by signing an ephemeral event.
    /// This kind is not meant to be published or queried.
    ///
    /// See [NIP-42](https://github.com/nostr-protocol/nips/blob/master/42.md).
    case authentication

    /// This kind of event is for long-form texxt content, generally referred to as "articles" or "blog posts".
    ///
    /// See [NIP-23](https://github.com/nostr-protocol/nips/blob/master/23.md).
    case longformContent
    
    /// This kind of event represents an occurrence that spans between a start date and end date.
    /// See [NIP-52 - Date-Based Calendar Event](https://github.com/nostr-protocol/nips/blob/master/52.md#calendar-events-1).
    case dateBasedCalendarEvent

    /// This kind of event represents an occurrence between moments in time.
    /// See [NIP-52 - Time-Based Calendar Event](https://github.com/nostr-protocol/nips/blob/master/52.md#time-based-calendar-event).
    case timeBasedCalendarEvent

    /// This kind of event represents a calendar, which is a collection of calendar events.
    /// It is represented as a custom replaceable list event. A user can have multiple calendars.
    /// One may create a calendar to segment calendar events for specific purposes. e.g., personal, work, travel, meetups, and conferences.
    /// See [NIP-52 - Calendar](https://github.com/nostr-protocol/nips/blob/master/52.md#calendar).
    case calendar

    /// This kind of event represents a calendar event RSVP, which is a response to a calendar event to indicate a user's attendance intention.
    /// See [NIP-52 - Calendar Event RSVP](https://github.com/nostr-protocol/nips/blob/master/52.md#calendar-event-rsvp).
    case calendarEventRSVP

    /// Any other event kind number that isn't supported by this enum yet will be represented by `unknown` so that `NostrEvent`s of those event kinds can still be encoded and decoded.
    case unknown(RawValue)

    /// List of all event kinds except for `unknown`.
    static public let allCases: AllCases = [
        .metadata,
        .textNote,
        .followList,
        .legacyEncryptedDirectMessage,
        .deletion,
        .repost,
        .reaction,
        .seal,
        .directMessage,
        .genericRepost,
        .giftWrap,
        .report,
        .muteList,
        .relayListMetadata,
        .bookmarksList,
        .authentication,
        .longformContent,
        .dateBasedCalendarEvent,
        .timeBasedCalendarEvent,
        .calendar,
        .calendarEventRSVP
    ]

    public init(rawValue: Int) {
        self = Self.allCases.first { $0.rawValue == rawValue }
               ?? .unknown(rawValue)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    public var rawValue: RawValue {
        switch self {
        case .metadata:                     return 0
        case .textNote:                     return 1
        case .followList:                   return 3
        case .legacyEncryptedDirectMessage: return 4
        case .deletion:                     return 5
        case .repost:                       return 6
        case .reaction:                     return 7
        case .seal:                         return 13
        case .directMessage:                return 14
        case .genericRepost:                return 16
        case .giftWrap:                     return 1059
        case .report:                       return 1984
        case .muteList:                     return 10000
        case .relayListMetadata:            return 10002
        case .bookmarksList:                return 10003
        case .authentication:               return 22242
        case .longformContent:              return 30023
        case .dateBasedCalendarEvent:       return 31922
        case .timeBasedCalendarEvent:       return 31923
        case .calendar:                     return 31924
        case .calendarEventRSVP:            return 31925
        case let .unknown(value):           return value
        }
    }

    /// The ``NostrEvent`` subclass associated with the kind.
    public var classForKind: NostrEvent.Type {
        switch self {
        case .metadata:                     return MetadataEvent.self
        case .textNote:                     return TextNoteEvent.self
        case .followList:                   return FollowListEvent.self
        case .legacyEncryptedDirectMessage: return LegacyEncryptedDirectMessageEvent.self
        case .deletion:                     return DeletionEvent.self
        case .repost:                       return TextNoteRepostEvent.self
        case .reaction:                     return ReactionEvent.self
        case .seal:                         return SealEvent.self
        case .directMessage:                return DirectMessageEvent.self
        case .genericRepost:                return GenericRepostEvent.self
        case .giftWrap:                     return GiftWrapEvent.self
        case .report:                       return ReportEvent.self
        case .muteList:                     return MuteListEvent.self
        case .relayListMetadata:            return RelayListMetadataEvent.self
        case .bookmarksList:                return BookmarksListEvent.self
        case .authentication:               return AuthenticationEvent.self
        case .longformContent:              return LongformContentEvent.self
        case .dateBasedCalendarEvent:       return DateBasedCalendarEvent.self
        case .timeBasedCalendarEvent:       return TimeBasedCalendarEvent.self
        case .calendar:                     return CalendarListEvent.self
        case .calendarEventRSVP:            return CalendarEventRSVP.self
        case .unknown:                      return NostrEvent.self
        }
    }

    /// For kind `n` such that `10000 <= n < 20000 || n == 0 || n == 3`, events are replaceable,
    /// which means that, for each combination of pubkey and kind,
    /// only the latest event MUST be stored by relays, older versions MAY be discarded.
    ///
    /// See [NIP-01 - Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#kinds).
    public var isNonParameterizedReplaceable: Bool {
        switch rawValue {
        case 10000..<20000, 0, 3: return true
        default: return false
        }
    }

    /// For kind `n` such that `30000 <= n < 40000`, events are parameterized replaceable,
    /// which means that, for each combination of pubkey, kind and the d tag's first value,
    /// only the latest event MUST be stored by relays, older versions MAY be discarded.
    ///
    /// See [NIP-01 - Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#kinds).
    public var isParameterizedReplaceable: Bool {
        (30000..<40000).contains(rawValue)
    }
}
