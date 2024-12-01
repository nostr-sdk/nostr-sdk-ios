//
//  CalendarEventBuilding.swift
//  NostrSDK
//
//  Created by Terry Yiu on 11/29/24.
//

import Foundation

/// Builder that adds calendar event tags to a ``NostrEvent``.
public protocol CalendarEventBuilding: NostrEventBuilding {}
public extension CalendarEventBuilding {
    /// Sets the unique identifier for the calendar event.
    /// Can be reused in the future for replacing the calendar event.
    /// If an identifier is not provided, a ``UUID`` string is used.
    @discardableResult
    func identifier(_ identifier: String) -> Self {
        appendTags(Tag(name: .identifier, value: identifier))
    }

    /// Sets the title of the calendar event.
    @discardableResult
    func title(_ title: String) -> Self {
        appendTags(Tag(name: .title, value: title))
    }

    /// Sets the detailed description of the calendar event.
    @discardableResult
    func description(_ description: String) -> Self {
        content(description)
    }

    /// Adds the locations of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    @discardableResult
    func locations(_ locations: [String]) -> Self {
        guard !locations.isEmpty else {
            return self
        }
        return appendTags(contentsOf: locations.map { Tag(name: "location", value: $0) })
    }

    /// Sets the [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    @discardableResult
    func geohash(_ geohash: String) -> Self {
        appendTags(Tag(name: "g", value: geohash))
    }

    /// Adds participants of the calendar event.
    @discardableResult
    func participants(_ participants: [CalendarEventParticipant]) -> Self {
        guard !participants.isEmpty else {
            return self
        }
        return appendTags(contentsOf: participants.map { $0.tag })
    }

    /// Adds hashtags to categorize the calendar event.
    @discardableResult
    func hashtags(_ hashtags: [String]) -> Self {
        guard !hashtags.isEmpty else {
            return self
        }
        return appendTags(contentsOf: hashtags.map { .hashtag($0) })
    }

    /// Adds references / links to web pages, documents, video calls, recorded videos, etc.
    @discardableResult
    func references(_ references: [URL]) -> Self {
        guard !references.isEmpty else {
            return self
        }
        return appendTags(contentsOf: references.map { Tag(name: .webURL, value: $0.absoluteString) })
    }
}
