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
    /// Start date is represented by ``DateComponents`` in the calendar context of ``Calendar.Identifier.iso8601``, with only `year`, `month`, and `day` populated.
    /// `nil` is returned if the backing `start` tag is malformed.
    public var start: DateComponents? {
        guard let startString = tags.first(where: { $0.name.rawValue == "start" })?.value else {
            return nil
        }

        return DateComponents(dateString: startString)
    }

    /// Exclusive end date.
    /// End date represented by ``DateComponents`` in the calendar context of ``Calendar.Identifier.iso8601``, with `year`, `month`, and `day` populated.
    /// `nil` is returned if the backing `end` tag is malformed or if the calendar event ends on the same date as start.
    public var end: DateComponents? {
        guard let endString = tags.first(where: { $0.name.rawValue == "end" })?.value else {
            return nil
        }

        return DateComponents(dateString: endString)
    }
}

extension DateComponents {
    /// Initializes a date components value from a string representation of a date in the format of yyyy-mm-dd.
    init?(dateString: String) {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "\\A(?<year>\\d{4})-(?<month>\\d{2})-(?<day>\\d{2})\\z")
        } catch {
            return nil
        }

        let matches = regex.matches(in: dateString, range: NSRange(location: 0, length: dateString.count))
        guard let match = matches.first else {
            return nil
        }

        var captures: [String: Int] = [:]

        // For each matched range, extract the named capture group
        for name in ["year", "month", "day"] {
            let matchRange = match.range(withName: name)

            // Extract the substring matching the named capture group
            if let substringRange = Range(matchRange, in: dateString) {
                let capture = Int(dateString[substringRange])
                captures[name] = capture
            }
        }

        guard let year = captures["year"], let month = captures["month"], let day = captures["day"] else {
            return nil
        }

        self.init(calendar: Calendar(identifier: .iso8601), year: year, month: month, day: day)

        // Documentation for DateComponents.isValidDate says that this method is not necessarily cheap.
        // If performance becomes a concern, reconsider if this check should be performed.
        guard isValidDate else {
            return nil
        }
    }
}
