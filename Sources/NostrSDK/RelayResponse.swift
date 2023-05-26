//
//  RelayResponse.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

import Foundation

enum RelayResponse: Decodable {

    struct CountResponse: Codable {
        let count: Int
    }

    enum MessageType: String, Codable {
        case event = "EVENT"
        case notice = "NOTICE"
        case eose = "EOSE"
        case ok = "OK"
        case count = "COUNT"
        case auth = "AUTH"
    }

    case notice(message: String)
    case eose(subscriptionId: String)
    case event(subscriptionId: String, event: NostrEvent)
    case ok(eventId: String, success: Bool, message: String)
    case count(subscriptionId: String, count: Int)
    case auth(challenge: String)

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let responseType = try container.decode(MessageType.self)
        switch responseType {
        case .event:
            let subscriptionId = try container.decode(String.self)
            let event = try container.decode(NostrEvent.self)
            self = .event(subscriptionId: subscriptionId, event: event)
        case .notice:
            let message = try container.decode(String.self)
            self = .notice(message: message)
        case .eose:
            let subscriptionId = try container.decode(String.self)
            self = .eose(subscriptionId: subscriptionId)
        case .ok:
            let eventId = try container.decode(String.self)
            let success = try container.decode(Bool.self)
            let message = try container.decode(String.self)
            self = .ok(eventId: eventId, success: success, message: message)
        case .count:
            let subscriptionId = try container.decode(String.self)
            let countResponse = try container.decode(CountResponse.self)
            self = .count(subscriptionId: subscriptionId, count: countResponse.count)
        case .auth:
            let challenge = try container.decode(String.self)
            self = .auth(challenge: challenge)
        }
    }

    static func decode(data: Data) -> Self? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Self.self, from: data)
        } catch {
            print("decode \(Self.Type.self) failed")
        }
        return nil
    }
}
