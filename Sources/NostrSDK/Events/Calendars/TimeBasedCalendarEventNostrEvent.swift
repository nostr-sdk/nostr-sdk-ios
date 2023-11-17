//
//  TimeBasedCalendarEventEvent.swift
//
//
//  Created by Terry Yiu on 11/16/23.
//

import Foundation

/// Time-based calendar event spans between a start time and end time.
public final class TimeBasedCalendarEventNostrEvent: NostrEvent, CalendarEventParticipantInterpreting, HashtagInterpreting, ReferenceTagInterpreting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .timeBasedCalendarEvent, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Universally unique identifier (UUID).
    public var uuid: String? {
        tags.first { $0.name.rawValue == "d" }?.value
    }

    /// The name of the calendar event.
    public var name: String? {
        tags.first { $0.name.rawValue == "name" }?.value
    }

    /// Inclusive start timestamp.
    /// The start timestamp is represented by ``Date``.
    /// `nil` is returned if the backing `start` tag is malformed.
    public var start: Date? {
        guard let startString = tags.first(where: { $0.name.rawValue == "start" })?.value, let startSeconds = Int(startString) else {
            return nil
        }

        return Date(timeIntervalSince1970: TimeInterval(startSeconds))
    }

    /// Exclusive end timestamp.
    /// End timestamp represented by ``Date``.
    /// `nil` is returned if the backing `end` tag is malformed or if the calendar event ends instanteously.
    public var end: Date? {
        guard let endString = tags.first(where: { $0.name.rawValue == "end" })?.value, let endSeconds = Int(endString) else {
            return nil
        }

        return Date(timeIntervalSince1970: TimeInterval(endSeconds))
    }

    /// The time zone of the start timestamp.
    public var startTimeZone: TimeZone? {
        guard let timeZoneIdentifier = tags.first(where: { $0.name.rawValue == "start_tzid" })?.value else {
            return nil
        }

        return TimeZone(identifier: timeZoneIdentifier)
    }

    /// The time zone of the end timestamp.
    /// `nil` can be returned if the time zone identifier is malformed or if the time zone of the end timestamp is the same as the start timestamp.
    public var endTimeZone: TimeZone? {
        guard let timeZoneIdentifier = tags.first(where: { $0.name.rawValue == "end_tzid" })?.value else {
            return nil
        }

        return TimeZone(identifier: timeZoneIdentifier)
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
