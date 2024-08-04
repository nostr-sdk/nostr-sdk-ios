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

public extension EventCreating {
    
    /// Creates a ``TimeBasedCalendarEvent`` (kind 31923) which spans between a start time and end time.
    /// - Parameters:
    ///   - identifier: A unique identifier for the calendar event. Can be reused in the future for replacing the calendar event. If an identifier is not provided, a ``UUID`` string is used.
    ///   - title: The title of the calendar event.
    ///   - summary: A brief summary of the calendar event.
    ///   - imageURL: A ``URL`` pointing to an image to be shown along with the title.
    ///   - description: A detailed description of the calendar event.
    ///   - startTimestamp: An inclusive start timestamp.
    ///   - endTimestamp: An exclusive end timestamp. If omitted, the calendar event ends instantaneously.
    ///   - startTimeZone: The time zone of the start timestamp.
    ///   - endTimeZone: The time zone of the end timestamp. If omitted and startTimeZone is provided, the time zone of the end timestamp is the same as the start timestamp.
    ///   - locations: The locations of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    ///   - geohash: The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    ///   - participants: The participants of the calendar event.
    ///   - hashtags: Hashtags to categorize the calendar event.
    ///   - references: References / links to web pages, documents, video calls, recorded videos, etc.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``TimeBasedCalendarEvent``.
    ///
    /// See [NIP-52](https://github.com/nostr-protocol/nips/blob/master/52.md).
    func timeBasedCalendarEvent(withIdentifier identifier: String = UUID().uuidString, title: String, summary: String? = nil, imageURL: URL? = nil, description: String = "", startTimestamp: Date, endTimestamp: Date? = nil, startTimeZone: TimeZone? = nil, endTimeZone: TimeZone? = nil, locations: [String]? = nil, geohash: String? = nil, participants: [CalendarEventParticipant]? = nil, hashtags: [String]? = nil, references: [URL]? = nil, signedBy keypair: Keypair) throws -> TimeBasedCalendarEvent {

        // If the end timestamp is omitted, the calendar event ends instantaneously.
        if let endTimestamp {
            // The start timestamp must occur before the end timestamp, if it exists.
            guard startTimestamp < endTimestamp else {
                throw EventCreatingError.invalidInput
            }
        }

        var tags: [Tag] = [
            Tag(name: .identifier, value: identifier),
            Tag(name: .title, value: title),
            Tag(name: "start", value: String(Int64(startTimestamp.timeIntervalSince1970)))
        ]

        if let summary {
            tags.append(Tag(name: .summary, value: summary))
        }

        if let imageURL {
            tags.append(Tag(name: .image, value: imageURL.absoluteString))
        }

        if let endTimestamp {
            tags.append(Tag(name: "end", value: String(Int64(endTimestamp.timeIntervalSince1970))))
        }
        
        if let startTimeZone {
            tags.append(Tag(name: "start_tzid", value: startTimeZone.identifier))
        }
        
        // If the end time zone is omitted and the start time zone is provided, the time zone of the end timestamp is the same as the start timestamp.
        if let endTimeZone {
            tags.append(Tag(name: "end_tzid", value: endTimeZone.identifier))
        }
        
        if let locations, !locations.isEmpty {
            tags += locations.map { Tag(name: "location", value: $0) }
        }
        
        if let geohash {
            tags.append(Tag(name: "g", value: geohash))
        }
        
        if let participants {
            tags += participants.map { $0.tag }
        }
        
        if let hashtags {
            tags += hashtags.map { .hashtag($0) }
        }
        
        if let references {
            tags += references.map { Tag(name: .webURL, value: $0.absoluteString) }
        }
        
        return try TimeBasedCalendarEvent(content: description, tags: tags, signedBy: keypair)
    }
}
