//
//  RelayRequest.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

import Foundation

struct RelayRequest {

    static let encoder = JSONEncoder()

    static func close(subscriptionId: String) -> String? {
        let payload = [AnyEncodable("CLOSE"), AnyEncodable(subscriptionId)]
        return encode(payload: payload)
    }

    static func event(_ event: NostrEvent) -> String? {
        let payload = [AnyEncodable("EVENT"), AnyEncodable(event)]
        return encode(payload: payload)
    }

    static func count(subscriptionId: String, filter: Filter) -> String? {
        let payload = [AnyEncodable("COUNT"), AnyEncodable(subscriptionId), AnyEncodable(filter)]
        return encode(payload: payload)
    }

    static func request(subscriptionId: String, filter: Filter) -> String? {
        let payload = [AnyEncodable("REQ"), AnyEncodable(subscriptionId), AnyEncodable(filter)]
        return encode(payload: payload)
    }

    private static func encode(payload: [AnyEncodable]) -> String? {
        guard let payloadData = try? encoder.encode(payload) else {
            return nil
        }
        return String(decoding: payloadData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
