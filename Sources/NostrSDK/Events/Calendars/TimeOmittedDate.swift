//
//  TimeOmittedDate.swift
//
//
//  Created by Terry Yiu on 11/19/23.
//

import Foundation

/// A representation of a date as it would appear in the ISO 8601 format, which is in the Gregorian calendar. Time and time zone are omitted.
public struct TimeOmittedDate: Comparable {
    public static func < (lhs: TimeOmittedDate, rhs: TimeOmittedDate) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }

        if lhs.month != rhs.month {
            return lhs.month < rhs.month
        }

        return lhs.day < rhs.day
    }

    /// The year of the date.
    public let year: Int

    /// The month of the date.
    public let month: Int

    /// The day of the date.
    public let day: Int

    /// Initializes a time-omitted date from an ISO 8601 year, month, and day.
    public init?(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day

        // Documentation for DateComponents.isValidDate says that this method is not necessarily cheap.
        // If performance becomes a concern, reconsider if this check should be performed.
        guard DateComponents(calendar: Calendar(identifier: .iso8601), timeZone: TimeZone(secondsFromGMT: 0), year: year, month: month, day: day).isValidDate else {
            return nil
        }
    }

    /// Initializes a time-omitted date from an ISO 8601 date string.
    public init?(dateString: String) {
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

        self.init(year: year, month: month, day: day)
    }

    /// The ISO 8601 string representation of the date in the format of yyyy-mm-dd.
    public var dateString: String {
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
