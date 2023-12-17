//
//  TimeBasedCalendarEvent.swift
//
//
//  Created by Terry Yiu on 11/16/23.
//

import Foundation

/// Time-based calendar event spans between a start time and end time.
public final class TimeBasedCalendarEvent: NostrEvent, CalendarEventInterpreting {
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

    /// Inclusive start timestamp.
    /// The start timestamp is represented by ``Date``.
    /// `nil` is returned if the backing `start` tag is malformed.
    public var startTimestamp: Date? {
        guard let startString = firstValueForRawTagName("start"), let startSeconds = Int(startString) else {
            return nil
        }

        return Date(timeIntervalSince1970: TimeInterval(startSeconds))
    }

    /// Exclusive end timestamp.
    /// End timestamp represented by ``Date``.
    /// `nil` is returned if the backing `end` tag is malformed or if the calendar event ends instanteously.
    public var endTimestamp: Date? {
        guard let endString = firstValueForRawTagName("end"), let endSeconds = Int(endString) else {
            return nil
        }

        return Date(timeIntervalSince1970: TimeInterval(endSeconds))
    }

    /// The time zone of the start timestamp.
    public var startTimeZone: TimeZone? {
        guard let timeZoneIdentifier = firstValueForRawTagName("start_tzid") else {
            return nil
        }

        return TimeZone(identifier: timeZoneIdentifier)
    }

    /// The time zone of the end timestamp.
    /// `nil` can be returned if the time zone identifier is malformed or if the time zone of the end timestamp is the same as the start timestamp.
    public var endTimeZone: TimeZone? {
        guard let timeZoneIdentifier = firstValueForRawTagName("end_tzid") else {
            return nil
        }

        return TimeZone(identifier: timeZoneIdentifier)
    }
}
