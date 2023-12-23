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

public protocol EventCreating: DirectMessageEncrypting, RelayURLValidating {}
public extension EventCreating {

    /// Creates a ``SetMetadataEvent`` (kind 0) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - userMetadata: The metadata to set.
    ///   - customEmojis: The custom emojis to emojify with if the matching shortcodes are found in the name or about fields.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``SetMetadataEvent``.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func setMetadataEvent(withUserMetadata userMetadata: UserMetadata, customEmojis: [CustomEmoji] = [], signedBy keypair: Keypair) throws -> SetMetadataEvent {
        let metadataAsData = try JSONEncoder().encode(userMetadata)
        guard let metadataAsString = String(data: metadataAsData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }
        let customEmojiTags = customEmojis.map { $0.tag }
        return try SetMetadataEvent(content: metadataAsString, tags: customEmojiTags, signedBy: keypair)
    }
    
    /// Creates a ``TextNoteEvent`` (kind 1) and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - content: The content of the text note.
    ///   - subject: A subject for the text note.
    ///   - customEmojis: The custom emojis to emojify with if the matching shortcodes are found in the content field.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TextNoteEvent``.
    ///
    /// See [NIP-01 - Basic Event Kinds](https://github.com/nostr-protocol/nips/blob/master/01.md#basic-event-kinds)
    func textNote(withContent content: String, subject: String? = nil, customEmojis: [CustomEmoji] = [], signedBy keypair: Keypair) throws -> TextNoteEvent {
        var tags: [Tag] = customEmojis.map { $0.tag }
        if let subject {
            tags.append(Tag(name: .subject, value: subject))
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
        do {
            try validateRelayURL(relayURL)
        } catch {
            throw EventCreatingError.invalidInput
        }

        return try RecommendServerEvent(content: relayURL.absoluteString, signedBy: keypair)
    }
    
    /// Creates a ``FollowListEvent`` (kind 3) following the provided pubkeys and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - pubkeys: The pubkeys of followed/known profiles to add to the follow list, in hex format.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``FollowListEvent``.
    ///
    /// Use this initializer if you do not intend to include petnames as part of the follow list.
    ///
    /// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md)
    func followList(withPubkeys pubkeys: [String], signedBy keypair: Keypair) throws -> FollowListEvent {
        try followList(withPubkeyTags: pubkeys.map { .pubkey($0) },
                        signedBy: keypair)
    }
    
    /// Creates a ``FollowListEvent`` (kind 3) with the provided pubkey tags and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - pubkeyTags: The pubkey tags of followed/known profiles to add to the follow list, which may include petnames.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``FollowListEvent``.
    ///
    /// Use this initializer if you intend to include petnames as part of the follow list.
    ///
    /// > Note: [NIP-02 Specification](https://github.com/nostr-protocol/nips/blob/master/02.md)
    func followList(withPubkeyTags pubkeyTags: [Tag], signedBy keypair: Keypair) throws -> FollowListEvent {
        guard !pubkeyTags.contains(where: { $0.name != TagName.pubkey.rawValue }) else {
            throw EventCreatingError.invalidInput
        }
        return try FollowListEvent(tags: pubkeyTags,
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

        let recipientTag = Tag.pubkey(pubkey.hex)
        return try DirectMessageEvent(content: encryptedMessage, tags: [recipientTag], signedBy: keypair)
    }
    
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
        var tags: [Tag] = [
            .event(event.id),
            .pubkey(event.pubkey)
        ]
        if event.kind == .textNote {
            return try TextNoteRepostEvent(content: stringifiedJSON, tags: tags, signedBy: keypair)
        } else {
            tags.append(.kind(event.kind))
            
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
        let eventTag = Tag.event(reactedEvent.id)
        let pubkeyTag = Tag.pubkey(reactedEvent.pubkey)

        var tags = reactedEvent.tags.filter { $0.name == TagName.event.rawValue || $0.name == TagName.pubkey.rawValue }
        tags.append(eventTag)
        tags.append(pubkeyTag)

        return try ReactionEvent(content: content, tags: tags, signedBy: keypair)
    }

    /// Creates a ``ReactionEvent`` (kind 7) in response to a different ``NostrEvent`` and signs it with the provided ``Keypair``.
    /// - Parameters:
    ///   - customEmoji: The custom emoji to emojify with if the matching shortcode is found in the content field.
    ///   - reactedEvent: The NostrEvent being reacted to.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``ReactionEvent``.
    ///
    /// See [NIP-25 - Reactions](https://github.com/nostr-protocol/nips/blob/master/25.md)
    func reaction(withCustomEmoji customEmoji: CustomEmoji, reactedEvent: NostrEvent, signedBy keypair: Keypair) throws -> ReactionEvent {
        let eventTag = Tag.event(reactedEvent.id)
        let pubkeyTag = Tag.pubkey(reactedEvent.pubkey)

        var tags = reactedEvent.tags.filter { $0.name == TagName.event.rawValue || $0.name == TagName.pubkey.rawValue }
        tags.append(eventTag)
        tags.append(pubkeyTag)
        tags.append(customEmoji.tag)

        return try ReactionEvent(content: ":\(customEmoji.shortcode):", tags: tags, signedBy: keypair)
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
                        tags: [.pubkey(pubkey.hex, otherParameters: [reportType.rawValue])],
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
        let tags: [Tag] = [
            .event(note.id, otherParameters: [reportType.rawValue]),
            .pubkey(note.pubkey)
        ]
        return try ReportEvent(content: additionalInformation, tags: tags, signedBy: keypair)
    }
    
    /// Creates a ``MuteListEvent`` (kind 10000) containing things the user doesn't want to see in their feeds. Mute list items be publicly visible or private.
    /// - Parameters:
    ///   - publiclyMutedPubkeys: Pubkeys to mute.
    ///   - privatelyMutedPubkeys: Pubkeys to secretly mute.
    ///   - publiclyMutedEventIds: Event ids to mute.
    ///   - privatelyMutedEventIds: Event ids to secretly mute.
    ///   - publiclyMutedHashtags: Hashtags to mute.
    ///   - privatelyMutedHashtags: Hashtags to secretly mute.
    ///   - publiclyMutedKeywords: Keywords to mute.
    ///   - privatelyMutedKeywords: Keywords to secretly mute.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``MuteListEvent``.
    func muteList(withPubliclyMutedPubkeys publiclyMutedPubkeys: [String] = [],
                  privatelyMutedPubkeys: [String] = [],
                  publiclyMutedEventIds: [String] = [],
                  privatelyMutedEventIds: [String] = [],
                  publiclyMutedHashtags: [String] = [],
                  privatelyMutedHashtags: [String] = [],
                  publiclyMutedKeywords: [String] = [],
                  privatelyMutedKeywords: [String] = [],
                  signedBy keypair: Keypair) throws -> MuteListEvent {
        var publicTags = [Tag]()
        
        for pubkey in publiclyMutedPubkeys {
            publicTags.append(.pubkey(pubkey))
        }
        for eventId in publiclyMutedEventIds {
            publicTags.append(.event(eventId))
        }
        for hashtag in publiclyMutedHashtags {
            publicTags.append(.hashtag(hashtag))
        }
        for keyword in publiclyMutedKeywords {
            publicTags.append(Tag(name: .word, value: keyword))
        }
        
        var secretTags = [[String]]()
        for pubkey in privatelyMutedPubkeys {
            secretTags.append([TagName.pubkey.rawValue, pubkey])
        }
        for eventId in privatelyMutedEventIds {
            secretTags.append([TagName.event.rawValue, eventId])
        }
        for hashtag in privatelyMutedHashtags {
            secretTags.append([TagName.hashtag.rawValue, hashtag])
        }
        for keyword in privatelyMutedKeywords {
            secretTags.append([TagName.word.rawValue, keyword])
        }
        
        var encryptedContent: String?
        if !secretTags.isEmpty {
            if let unencryptedData = try? JSONSerialization.data(withJSONObject: secretTags),
               let unencryptedContent = String(data: unencryptedData, encoding: .utf8) {
                encryptedContent = try encrypt(content: unencryptedContent,
                                               privateKey: keypair.privateKey,
                                               publicKey: keypair.publicKey)
            }
        }
        
        return try MuteListEvent(content: encryptedContent ?? "", tags: publicTags, signedBy: keypair)
    }
    
    /// Creates a ``LongformContentEvent`` (kind 30023, a parameterized replaceable event) for long-form text content, generally referred to as "articles" or "blog posts".
    /// - Parameters:
    ///   - identifier: A unique identifier for the content. Can be reused in the future for replacing the event. If an identifier is not provided, a ``UUID`` string is used.
    ///   - title: The article title.
    ///   - markdownContent: A string text in Markdown syntax.
    ///   - summary: A summary of the content.
    ///   - imageURL: A URL pointing to an image to be shown along with the title.
    ///   - hashtags: An optional list of topics about which the event might be of relevance.
    ///   - publishedAt: The date of the first time the article was published.
    ///   - keypair: The ``Keypair`` to sign with.
    /// - Returns: The signed ``LongformContentEvent``.
    func longformContentEvent(withIdentifier identifier: String = UUID().uuidString,
                              title: String? = nil,
                              markdownContent: String,
                              summary: String? = nil,
                              imageURL: URL? = nil,
                              hashtags: [String]? = nil,
                              publishedAt: Date = .now,
                              signedBy keypair: Keypair) throws -> LongformContentEvent {
        var tags = [Tag]()
        
        tags.append(Tag(name: .identifier, value: identifier))
        
        if let title {
            tags.append(Tag(name: .title, value: title))
        }
        
        if let summary {
            tags.append(Tag(name: .summary, value: summary))
        }
        
        if let imageURL {
            tags.append(Tag(name: .image, value: imageURL.absoluteString))
        }
        
        if let hashtags {
            for hashtag in hashtags {
                tags.append(.hashtag(hashtag))
            }
        }
        
        tags.append(Tag(name: .publishedAt, value: String(Int64(publishedAt.timeIntervalSince1970))))
        
        return try LongformContentEvent(content: markdownContent, tags: tags, signedBy: keypair)
    }

    /// Creates a ``DateBasedCalendarEvent`` (kind 31922) which starts on a date and ends before a different date in the future.
    /// Its use is appropriate for all-day or multi-day events where time and time zone hold no significance. e.g., anniversary, public holidays, vacation days.
    /// - Parameters:
    ///   - identifier: A unique identifier for the calendar event. Can be reused in the future for replacing the calendar event. If an identifier is not provided, a ``UUID`` string is used.
    ///   - title: The title of the calendar event.
    ///   - description: A detailed description of the calendar event.
    ///   - startDate: An inclusive start date. Must be less than end, if it exists. If there are any components other than year, month,
    ///   - endDate: An exclusive end date. If omitted, the calendar event ends on the same date as start.
    ///   - locations: The locations of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    ///   - geohash: The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    ///   - participants: The participants of the calendar event.
    ///   - hashtags: Hashtags to categorize the calendar event.
    ///   - references: References / links to web pages, documents, video calls, recorded videos, etc.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``DateBasedCalendarEvent``.
    ///
    /// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
    func dateBasedCalendarEvent(withIdentifier identifier: String = UUID().uuidString, title: String, description: String = "", startDate: TimeOmittedDate, endDate: TimeOmittedDate? = nil, locations: [String]? = nil, geohash: String? = nil, participants: [CalendarEventParticipant]? = nil, hashtags: [String]? = nil, references: [URL]? = nil, signedBy keypair: Keypair) throws -> DateBasedCalendarEvent {

        var tags: [Tag] = []

        // If the end date is omitted, the calendar event ends on the same date as the start date.
        if let endDate {
            // The start date must occur before the end date, if it exists.
            guard startDate < endDate else {
                throw EventCreatingError.invalidInput
            }

            tags.append(Tag(name: "end", value: endDate.dateString))
        }

        // Re-arrange tags so that it's easier to read with the identifier and name appearing first in the list of tags,
        // and the end date being placed next to the start date.
        tags = [
            Tag(name: .identifier, value: identifier),
            Tag(name: .title, value: title),
            Tag(name: "start", value: startDate.dateString)
        ] + tags

        if let locations, !locations.isEmpty {
            tags += locations.map { Tag(name: "location", value: $0) }
        }

        if let geohash {
            tags.append(Tag(name: "g", value: geohash))
        }

        if let participants, !participants.isEmpty {
            tags += participants.map { $0.tag }
        }

        if let hashtags, !hashtags.isEmpty {
            tags += hashtags.map { .hashtag($0) }
        }

        if let references, !references.isEmpty {
            tags += references.map { Tag(name: .webURL, value: $0.absoluteString) }
        }

        return try DateBasedCalendarEvent(content: description, tags: tags, signedBy: keypair)
    }

    /// Creates a ``TimeBasedCalendarEvent`` (kind 31923) which spans between a start time and end time.
    /// - Parameters:
    ///   - identifier: A unique identifier for the calendar event. Can be reused in the future for replacing the calendar event. If an identifier is not provided, a ``UUID`` string is used.
    ///   - title: The title of the calendar event.
    ///   - description: A detailed description of the calendar event.
    ///   - startTimestamp: An inclusive start timestamp.
    ///   - endTimestamp: An exclusive end timestamp. If omitted, the calendar event ends instantaneously.
    ///   - startTimeZone: The time zone of the start timestamp.
    ///   - endTimeZone: The time zone of the end timestamp. If omitted and startTimeZone is provided, the time zone of the end timestamp is the same as the start timestamp.
    ///   - locations: The locations of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    ///   - geohash: The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    ///   - participants: The participants of the calendar event.
    ///   - hashtags: Hashtags to categorize the calendar event.
    ///   - references: References / links to web pages, documents, video calls, recorded videos, etc.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TimeBasedCalendarEvent``.
    ///
    /// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
    func timeBasedCalendarEvent(withIdentifier identifier: String = UUID().uuidString, title: String, description: String = "", startTimestamp: Date, endTimestamp: Date? = nil, startTimeZone: TimeZone? = nil, endTimeZone: TimeZone? = nil, locations: [String]? = nil, geohash: String? = nil, participants: [CalendarEventParticipant]? = nil, hashtags: [String]? = nil, references: [URL]? = nil, signedBy keypair: Keypair) throws -> TimeBasedCalendarEvent {

        // If the end timestamp is omitted, the calendar event ends instantaneously.
        if let endTimestamp {
            // The start timestamp must occur before the end timestamp, if it exists.
            guard startTimestamp < endTimestamp else {
                throw EventCreatingError.invalidInput
            }
        }

        var tags: [Tag] = [
            Tag(name: .identifier, value: identifier),
            Tag(name: .title, value: title),
            Tag(name: "start", value: String(Int64(startTimestamp.timeIntervalSince1970)))
        ]

        if let endTimestamp {
            tags.append(Tag(name: "end", value: String(Int64(endTimestamp.timeIntervalSince1970))))
        }

        if let startTimeZone {
            tags.append(Tag(name: "start_tzid", value: startTimeZone.identifier))
        }

        // If the end time zone is omitted and the start time zone is provided, the time zone of the end timestamp is the same as the start timestamp.
        if let endTimeZone {
            tags.append(Tag(name: "end_tzid", value: endTimeZone.identifier))
        }

        if let locations, !locations.isEmpty {
            tags += locations.map { Tag(name: "location", value: $0) }
        }

        if let geohash {
            tags.append(Tag(name: "g", value: geohash))
        }

        if let participants {
            tags += participants.map { $0.tag }
        }

        if let hashtags {
            tags += hashtags.map { .hashtag($0) }
        }

        if let references {
            tags += references.map { Tag(name: .webURL, value: $0.absoluteString) }
        }

        return try TimeBasedCalendarEvent(content: description, tags: tags, signedBy: keypair)
    }

    /// Creates a ``CalendarListEvent`` (kind 31924), which is a collection of date-based and time-based calendar events.
    /// - Parameters:
    ///   - identifier: A unique identifier for the calendar. Can be reused in the future for replacing the calendar. If an identifier is not provided, a ``UUID`` string is used.
    ///   - title: The title of the calendar.
    ///   - description: A detailed description of the calendar.
    ///   - calendarEventsCoordinates: The coordinates to date-based or time-based calendar events that belong to this calendar.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``CalendarListEvent``.
    ///
    /// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
    func calendarListEvent(withIdentifier identifier: String = UUID().uuidString, title: String, description: String = "", calendarEventsCoordinates: [EventCoordinates], signedBy keypair: Keypair) throws -> CalendarListEvent {
        guard calendarEventsCoordinates.allSatisfy({ $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }) else {
            throw EventCreatingError.invalidInput
        }

        var tags: [Tag] = [
            Tag(name: .identifier, value: identifier),
            Tag(name: .title, value: title)
        ]

        calendarEventsCoordinates
            .filter { $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }
            .forEach { tags.append($0.tag) }

        return try CalendarListEvent(content: description, tags: tags, signedBy: keypair)
    }

    /// Creates a ``CalendarEventRSVP`` (kind 31925), which is a response to a calendar event to indicate a user's attendance intention.
    /// - Parameters:
    ///   - identifier: A unique identifier for the calendar event RSVP. Can be reused in the future for replacing the calendar event RSVP. If an identifier is not provided, a ``UUID`` string is used.
    ///   - calendarEventCoordinates: The coordinates to date-based or time-based calendar event being responded to.
    ///   - status: The attendance status to the referenced calendar event. Mimics the Participation Status type in the [RFC 5545 iCalendar spec](https://datatracker.ietf.org/doc/html/rfc5545#section-3.2.12).
    ///   - freebusy: Whether the user would be free or busy for the duration of the calendar event. This tag must be omitted or ignored if the status label is set to declined. Mimics the Free/Busy Time Type in the [RFC 5545 iCalendar spec](https://datatracker.ietf.org/doc/html/rfc5545#section-3.2.9).
    ///   - note: A free-form note that adds more context to this calendar event response.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``CalendarEventRSVP``.
    ///
    /// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
    func calendarEventRSVP(withIdentifier identifier: String = UUID().uuidString, calendarEventCoordinates: EventCoordinates, status: CalendarEventRSVPStatus, freebusy: CalendarEventRSVPFreebusy? = nil, note: String = "", signedBy keypair: Keypair) throws -> CalendarEventRSVP {
        guard calendarEventCoordinates.kind == .dateBasedCalendarEvent || calendarEventCoordinates.kind == .timeBasedCalendarEvent,
              // Status must not be unknown, and freebusy must be omitted if status is declined.
              status == .accepted || status == .tentative || (status == .declined && freebusy == nil) else {
            throw EventCreatingError.invalidInput
        }

        var tags: [Tag] = [
            calendarEventCoordinates.tag,
            Tag(name: .identifier, value: identifier),
            Tag(name: .labelNamespace, value: "status"),
            Tag(name: .label, value: status.rawValue, otherParameters: ["status"])
        ]

        if let freebusy {
            tags.append(Tag(name: .labelNamespace, value: "freebusy"))
            tags.append(Tag(name: .label, value: freebusy.rawValue, otherParameters: ["freebusy"]))
        }

        return try CalendarEventRSVP(content: note, tags: tags, signedBy: keypair)
    }
}
