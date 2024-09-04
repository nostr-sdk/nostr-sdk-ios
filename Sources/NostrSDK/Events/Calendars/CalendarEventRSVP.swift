//
//  CalendarEventRSVP.swift
//  
//
//  Created by Terry Yiu on 12/1/23.
//

import Foundation

/// A calendar event RSVP is a response to a calendar event to indicate a user's attendance intention.
/// 
/// See [NIP-52 - Calendar Event RSVP](https://github.com/nostr-protocol/nips/blob/master/52.md#calendar-event-rsvp).
public final class CalendarEventRSVP: NostrEvent, ParameterizedReplaceableEvent {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .calendarEventRSVP, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Event coordinates to the calendar event this RSVP responds to.
    public var calendarEventCoordinates: EventCoordinates? {
        tags.compactMap { EventCoordinates(eventCoordinatesTag: $0) }
            .first { $0.kind == .dateBasedCalendarEvent || $0.kind == .timeBasedCalendarEvent }
    }

    /// The attendance status to the referenced calendar event.
    ///  Mimics the Participation Status type in the [RFC 5545 iCalendar spec](https://datatracker.ietf.org/doc/html/rfc5545#section-3.2.12).
    public var status: CalendarEventRSVPStatus? {
        guard let status = firstValueForRawTagName("status") else {
            return nil
        }

        return CalendarEventRSVPStatus(rawValue: status)
    }

    /// Whether the user is free or busy for the duration of the calendar event.
    /// Mimics the Free/Busy Time Type in the [RFC 5545 iCalendar spec](https://datatracker.ietf.org/doc/html/rfc5545#section-3.2.9).
    public var freebusy: CalendarEventRSVPFreebusy? {
        guard let freebusy = firstValueForRawTagName("fb") else {
            return nil
        }

        return CalendarEventRSVPFreebusy(rawValue: freebusy)
    }
}

public extension EventCreating {

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
            Tag(name: "status", value: status.rawValue)
        ]

        if let freebusy {
            tags.append(Tag(name: "fb", value: freebusy.rawValue))
        }

        return try CalendarEventRSVP(content: note, tags: tags, signedBy: keypair)
    }
}
