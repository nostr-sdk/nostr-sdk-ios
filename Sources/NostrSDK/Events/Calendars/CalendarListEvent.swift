//
//  CalendarListEvent.swift
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
public final class CalendarListEvent: NostrEvent, ParameterizedReplaceableEvent, ImageTagInterpreting, TitleTagInterpreting {
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
    public var calendarEventCoordinateList: [EventCoordinates] {
        tags.compactMap { EventCoordinates(eventCoordinatesTag: $0) }
            .filter { $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }
    }
}

public extension EventCreating {
    
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
    func calendarListEvent(withIdentifier identifier: String = UUID().uuidString, title: String, description: String = "", calendarEventsCoordinates: [EventCoordinates], imageURL: URL? = nil, signedBy keypair: Keypair) throws -> CalendarListEvent {
        guard calendarEventsCoordinates.allSatisfy({ $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }) else {
            throw EventCreatingError.invalidInput
        }
        
        var tags: [Tag] = [
            Tag(name: .identifier, value: identifier),
            Tag(name: .title, value: title)
        ]

        if let imageURL {
            tags.append(Tag(name: .image, value: imageURL.absoluteString))
        }

        calendarEventsCoordinates
            .filter { $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }
            .forEach { tags.append($0.tag) }
        
        return try CalendarListEvent(content: description, tags: tags, signedBy: keypair)
    }
}
