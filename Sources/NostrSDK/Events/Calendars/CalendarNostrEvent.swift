//
//  CalendarNostrEvent.swift
//
//
//  Created by Terry Yiu on 12/1/23.
//

import Foundation

/// A calendar is a collection of calendar events, represented as a custom replaceable list event.
/// A user can have multiple calendars.
/// One may create a calendar to segment calendar events for specific purposes. e.g., personal, work, travel, meetups, and conferences.
///
/// See [NIP-52 - Calendar](https://github.com/nostr-protocol/nips/blob/master/52.md#calendar).
public final class CalendarNostrEvent: NostrEvent, IdentifierTagInterpreting, TitleTagInterpreting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .calendar, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// The event coordinates of the calendar events that belong to this calendar.
    public var calendarEventsCoordinates: [EventCoordinates] {
        tags.compactMap { EventCoordinates(eventCoordinatesTag: $0) }
            .filter { $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }
    }
}
