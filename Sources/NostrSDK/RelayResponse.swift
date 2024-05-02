//
//  RelayResponse.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

import Foundation

/// A type used for decoding and mapping a kind number to a ``NostrEvent`` subclass.
fileprivate struct EventKindMapper: Decodable {     // swiftlint:disable:this private_over_fileprivate
    let kind: EventKind
    
    enum CodingKeys: CodingKey {
        case kind
    }
    
    /// The ``NostrEvent`` subclass associated with the kind.
    var classForKind: NostrEvent.Type {
        kind.classForKind
    }
}

enum RelayResponse: Decodable {

    struct CountResponse: Codable {
        let count: Int
    }

    enum MessageType: String, Codable {
        case event = "EVENT"
        case ok = "OK"
        case eose = "EOSE"
        case closed = "CLOSED"
        case notice = "NOTICE"
        case auth = "AUTH"
        case count = "COUNT"
    }
    
    struct RelayResponseMessage {
        let prefix: RelayResponseMessagePrefix
        let message: String
        
        init(rawMessage: String) {
            let components = rawMessage.split(separator: ":", maxSplits: 1)
            if let firstComponent = components.first {
                prefix = RelayResponseMessagePrefix(rawValue: String(firstComponent)) ?? .unknown
            } else {
                prefix = .unknown
            }

            if prefix == .unknown {
                message = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if components.count >= 2 {
                message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                message = ""
            }
        }
    }
    
    enum RelayResponseMessagePrefix: String, Codable {
        case unknown
        case duplicate
        case pow
        case blocked
        case rateLimited = "rate-limited"
        case invalid
        case error
    }

    case event(subscriptionId: String, event: NostrEvent)
    case ok(eventId: String, success: Bool, message: RelayResponseMessage)
    case eose(subscriptionId: String)
    case closed(subscriptionId: String, message: RelayResponseMessage)
    case notice(message: String)
    case auth(challenge: String)
    case count(subscriptionId: String, count: Int)

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let responseType = try container.decode(MessageType.self)
        switch responseType {
        case .event:
            let subscriptionId = try container.decode(String.self)
            let kindMapper = try container.decode(EventKindMapper.self)
            
            // Since the decoding index in the container cannot be decremented, create a
            // new container so we can use the class from the mapper.
            var container2 = try decoder.unkeyedContainer()
            _ = try? container2.decode(MessageType.self)
            _ = try? container2.decode(String.self)
            let event = try container2.decode(kindMapper.classForKind.self)
            
            self = .event(subscriptionId: subscriptionId, event: event)
        case .ok:
            let eventId = try container.decode(String.self)
            let success = try container.decode(Bool.self)
            let message = try container.decode(String.self)
            self = .ok(eventId: eventId, success: success, message: RelayResponseMessage(rawMessage: message))
        case .eose:
            let subscriptionId = try container.decode(String.self)
            self = .eose(subscriptionId: subscriptionId)
        case .closed:
            let subscriptionId = try container.decode(String.self)
            let message = try container.decode(String.self)
            self = .closed(subscriptionId: subscriptionId, message: RelayResponseMessage(rawMessage: message))
        case .notice:
            let message = try container.decode(String.self)
            self = .notice(message: message)
        case .auth:
            let challenge = try container.decode(String.self)
            self = .auth(challenge: challenge)
        case .count:
            let subscriptionId = try container.decode(String.self)
            let countResponse = try container.decode(CountResponse.self)
            self = .count(subscriptionId: subscriptionId, count: countResponse.count)
        }
    }

    static func decode(data: Data) -> Self? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Self.self, from: data)
        } catch {
            Loggers.relayDecoding.error("decode \(Self.Type.self) failed: \(error)")
        }
        return nil
    }
}
