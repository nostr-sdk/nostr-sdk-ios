//
//  CalendarEventInterpreting.swift
//
//
//  Created by Terry Yiu on 11/19/23.
//

import Foundation

public protocol CalendarEventInterpreting: NostrEvent, CalendarEventParticipantInterpreting, HashtagInterpreting, ReferenceTagInterpreting {}
public extension CalendarEventInterpreting {
    /// Universally unique identifier (UUID).
    var uuid: String? {
        tags.first { $0.name == TagName.identifier.rawValue }?.value
    }

    /// The name of the calendar event.
    var name: String? {
        tags.first { $0.name == "name" }?.value
    }

    /// The location of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    var location: String? {
        tags.first { $0.name == "location" }?.value
    }

    /// The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    var geohash: String? {
        tags.first { $0.name == "g" }?.value
    }
}
