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
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    public init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .dateBasedCalendarEvent, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    /// Inclusive start date.
    /// Start date is represented by ``TimeOmittedDate``.
    /// `nil` is returned if the backing `start` tag is malformed.
    public var startDate: TimeOmittedDate? {
        guard let startString = valueForRawTagName("start") else {
            return nil
        }

        return TimeOmittedDate(dateString: startString)
    }

    /// Exclusive end date.
    /// End date represented by ``TimeOmittedDate``.
    /// `nil` is returned if the backing `end` tag is malformed or if the calendar event ends on the same date as start.
    public var endDate: TimeOmittedDate? {
        guard let endString = valueForRawTagName("end") else {
            return nil
        }

        return TimeOmittedDate(dateString: endString)
    }
}
