//
//  CalendarEventParticipant.swift
//
//
//  Created by Terry Yiu on 11/15/23.
//

import Foundation

/// A participant in a calendar event.
public struct CalendarEventParticipant: PubkeyProviding, RelayProviding, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag
    }

    /// The tag representation of this calendar event participant.
    public let tag: Tag

    /// The public key of the participant.
    public var pubkey: PublicKey? {
        PublicKey(hex: tag.value)
    }

    /// A relay in which the participant can be found. nil is returned if the relay URL is malformed.
    public var relayURL: URL? {
        guard let relayString = tag.otherParameters.first else {
            return nil
        }
        guard !relayString.isEmpty else {
            return nil
        }

        let components = URLComponents(string: relayString)
        guard components?.scheme == "wss" || components?.scheme == "ws" else {
            return nil
        }
        return components?.url
    }

    /// The role of the participant in the meeting.
    public var role: String? {
        guard tag.otherParameters.count >= 2 else {
            return nil
        }

        return tag.otherParameters[1]
    }

    public init?(pubkeyTag: Tag) {
        guard pubkeyTag.name == .pubkey else {
            return nil
        }

        self.tag = pubkeyTag
    }

    public init(pubkey: PublicKey, relayURL: URL? = nil, role: String? = nil) {
        var otherParameters: [String] = [relayURL?.absoluteString ?? ""]
        if let role, !role.isEmpty {
            otherParameters.append(role)
        }

        tag = Tag(name: .pubkey, value: pubkey.hex, otherParameters: otherParameters)
    }
}

/// Interprets calendar event participant tags.
public protocol CalendarEventParticipantInterpreting: NostrEvent {}
public extension CalendarEventParticipantInterpreting {
    var participants: [CalendarEventParticipant] {
        tags.filter { $0.name == .pubkey }.compactMap { CalendarEventParticipant(pubkeyTag: $0) }
    }
}
