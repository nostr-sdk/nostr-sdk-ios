//
//  DateBasedCalendarEventNostrEvent.swift
//
//
//  Created by Terry Yiu on 11/13/23.
//

import Foundation

/// Date-based calendar event starts on a date and ends before a different date in the future.
/// Its use is appropriate for all-day or multi-day events where time and time zone hold no significance. e.g., anniversary, public holidays, vacation days.
/// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
public final class DateBasedCalendarEventNostrEvent: NostrEvent, CalendarEventParticipantInterpreting, HashtagInterpreting, ReferenceTagInterpreting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .dateBasedCalendarEvent, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Universally unique identifier (UUID).
    public var uuid: String? {
        tags.first { $0.name.rawValue == "d" }?.value
    }

    /// The name of the calendar event.
    public var name: String? {
        tags.first { $0.name.rawValue == "name" }?.value
    }

    /// Inclusive start date.
    /// Start date is represented by ``DateComponents`` in the calendar context of ``Calendar.Identifier.iso8601``, with only `year`, `month`, and `day` populated.
    /// `nil` is returned if the backing `start` tag is malformed.
    public var start: DateComponents? {
        guard let startString = tags.first(where: { $0.name.rawValue == "start" })?.value else {
            return nil
        }

        return startString.dateStringAsDateComponents
    }

    /// Exclusive end date.
    /// End date represented by ``DateComponents`` in the calendar context of ``Calendar.Identifier.iso8601``, with `year`, `month`, and `day` populated.
    /// `nil` is returned if the backing `end` tag is malformed or if the calendar event ends on the same date as start.
    public var end: DateComponents? {
        guard let endString = tags.first(where: { $0.name.rawValue == "end" })?.value else {
            return nil
        }

        return endString.dateStringAsDateComponents
    }

    /// The location of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    public var location: String? {
        tags.first { $0.name.rawValue == "location" }?.value
    }

    /// The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    public var geohash: String? {
        tags.first { $0.name.rawValue == "g" }?.value
    }
}
