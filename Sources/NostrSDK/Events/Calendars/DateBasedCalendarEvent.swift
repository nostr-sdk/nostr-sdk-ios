//
//  DateBasedCalendarEvent.swift
//
//
//  Created by Terry Yiu on 11/13/23.
//

import Foundation

/// Date-based calendar event starts on a date and ends before a different date in the future.
/// Its use is appropriate for all-day or multi-day events where time and time zone hold no significance. e.g., anniversary, public holidays, vacation days.
/// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
public final class DateBasedCalendarEvent: NostrEvent, CalendarEventInterpreting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .dateBasedCalendarEvent, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Inclusive start date.
    /// Start date is represented by ``TimeOmittedDate``.
    /// `nil` is returned if the backing `start` tag is malformed.
    public var startDate: TimeOmittedDate? {
        guard let startString = firstValueForRawTagName("start") else {
            return nil
        }

        return TimeOmittedDate(dateString: startString)
    }

    /// Exclusive end date.
    /// End date represented by ``TimeOmittedDate``.
    /// `nil` is returned if the backing `end` tag is malformed or if the calendar event ends on the same date as start.
    public var endDate: TimeOmittedDate? {
        guard let endString = firstValueForRawTagName("end") else {
            return nil
        }

        return TimeOmittedDate(dateString: endString)
    }
}

public extension EventCreating {
    
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
    @available(*, deprecated, message: "Deprecated in favor of DateBasedCalendarEvent.Builder.")
    func dateBasedCalendarEvent(withIdentifier identifier: String = UUID().uuidString, title: String, description: String = "", startDate: TimeOmittedDate, endDate: TimeOmittedDate? = nil, locations: [String]? = nil, geohash: String? = nil, participants: [CalendarEventParticipant]? = nil, hashtags: [String]? = nil, references: [URL]? = nil, signedBy keypair: Keypair) throws -> DateBasedCalendarEvent {

        let builder = try DateBasedCalendarEvent.Builder()
            .identifier(identifier)
            .title(title)
            .description(description)
            .dates(from: startDate, to: endDate)

        if let locations {
            builder.locations(locations)
        }

        if let geohash {
            builder.geohash(geohash)
        }

        if let participants {
            builder.participants(participants)
        }

        if let hashtags {
            builder.hashtags(hashtags)
        }

        if let references {
            builder.references(references)
        }

        return try builder.build(signedBy: keypair)
    }
}

public extension DateBasedCalendarEvent {
    /// Builder of a ``DateBasedCalendarEvent``.
    final class Builder: NostrEvent.Builder<DateBasedCalendarEvent>, CalendarEventBuilding {
        public init() {
            super.init(kind: .dateBasedCalendarEvent)
        }

        @discardableResult
        public final func dates(from startDate: TimeOmittedDate, to endDate: TimeOmittedDate? = nil) throws -> Builder {
            // If the end date is omitted, the calendar event ends on the same date as the start date.
            if let endDate {
                // The start date must occur before the end date, if it exists.
                guard startDate < endDate else {
                    throw EventCreatingError.invalidInput
                }
            }

            appendTags(Tag(name: "start", value: startDate.dateString))

            if let endDate {
                appendTags(Tag(name: "end", value: endDate.dateString))
            }

            return self
        }
    }
}
