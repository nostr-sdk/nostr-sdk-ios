//
//  CalendarEventRSVPStatus.swift
//  
//
//  Created by Terry Yiu on 12/17/23.
//

import Foundation

/// A calendar event RSVP is a response to a calendar event to indicate a user's attendance intention.
public enum CalendarEventRSVPStatus: RawRepresentable, CaseIterable, Codable, Equatable {

    public typealias RawValue = String

    /// The user has accepted to attend the calendar event.
    case accepted

    /// The user has declined to attend the calendar event.
    case declined

    /// The user has tentatively accepted to attend the calendar event.
    case tentative

    /// Unknown RSVP status.
    case unknown(RawValue)

    static public let allCases: AllCases = [
        .accepted,
        .declined,
        .tentative
    ]

    public init(rawValue: String) {
        self = Self.allCases.first { $0.rawValue == rawValue }
               ?? .unknown(rawValue)
    }

    public var rawValue: RawValue {
        switch self {
        case .accepted: return "accepted"
        case .declined: return "declined"
        case .tentative: return "tentative"
        case let .unknown(value): return value
        }
    }
}
