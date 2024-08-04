//
//  CalendarEventInterpreting.swift
//
//
//  Created by Terry Yiu on 11/19/23.
//

import Foundation

public protocol CalendarEventInterpreting: NostrEvent, CalendarEventParticipantInterpreting, HashtagInterpreting, ImageTagInterpreting, ParameterizedReplaceableEvent, ReferenceTagInterpreting, SummaryTagInterpreting, TitleTagInterpreting {}
public extension CalendarEventInterpreting {
    /// The locations of the calendar event. e.g. address, GPS coordinates, meeting room name, link to video call.
    var locations: [String] {
        tags.filter { $0.name == "location" }.map { $0.value }
    }

    /// The [geohash](https://en.wikipedia.org/wiki/Geohash) to associate calendar event with a searchable physical location.
    var geohash: String? {
        tags.first { $0.name == "g" }?.value
    }
}
