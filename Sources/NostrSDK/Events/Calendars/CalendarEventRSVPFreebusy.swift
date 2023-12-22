//
//  CalendarEventRSVPFreebusy.swift
//
//
//  Created by Terry Yiu on 12/17/23.
//

import Foundation

/// A type for describing whether the user is free or busy for the duration of the calendar event.
public enum CalendarEventRSVPFreebusy: RawRepresentable, CaseIterable, Codable, Equatable {

    public typealias RawValue = String

    /// The user is free for the duration of the calendar event.
    case free

    /// The user is busy for the duration of the calendar event.
    case busy

    /// Unknown freebusy state.
    case unknown(RawValue)

    static public let allCases: AllCases = [
        .free,
        .busy
    ]

    public init(rawValue: String) {
        self = Self.allCases.first { $0.rawValue == rawValue }
               ?? .unknown(rawValue)
    }

    public var rawValue: RawValue {
        switch self {
        case .free: return "free"
        case .busy: return "busy"
        case let .unknown(value): return value
        }
    }
}
