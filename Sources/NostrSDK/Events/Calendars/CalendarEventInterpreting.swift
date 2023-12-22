//
//  CalendarEventInterpreting.swift
//
//
//  Created by Terry Yiu on 11/19/23.
//

import Foundation

public protocol CalendarEventInterpreting: NostrEvent, CalendarEventParticipantInterpreting, HashtagInterpreting, IdentifierTagInterpreting, ReferenceTagInterpreting, TitleTagInterpreting {}
public extension CalendarEventInterpreting {
    /// The name of the calendar event.
    @available(*, deprecated, message: "This method of naming a calendar event is out of spec, not preferred, and will be removed in the future. Please use only the title field when it is available.")
    var name: String? {
        tags.first { $0.name == "name" }?.value
    }

    /// The locations of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    var locations: [String] {
        tags.filter { $0.name == "location" }.map { $0.value }
    }

    /// The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    var geohash: String? {
        tags.first { $0.name == "g" }?.value
    }
}
