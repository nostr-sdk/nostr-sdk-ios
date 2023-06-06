//
//  RelayRequest.swift
//  
//
//  Created by Joel Klabo on 5/25/23.
//

import Foundation

enum RelayRequest {
    case close(subscriptionId: String)
    case event(NostrEvent)
    case count(subscriptionId: String, filter: Filter)
    case request(subscriptionId: String, filter: Filter)
    
    var encoded: String? {
        let payload: [AnyEncodable]
        switch self {
        case .close(let subscriptionId):
            payload = [AnyEncodable("CLOSE"), AnyEncodable(subscriptionId)]
        case .event(let event):
            payload = [AnyEncodable("EVENT"), AnyEncodable(event)]
        case .count(let subscriptionId, let filter):
            payload = [AnyEncodable("COUNT"), AnyEncodable(subscriptionId), AnyEncodable(filter)]
        case .request(let subscriptionId, let filter):
            payload = [AnyEncodable("REQ"), AnyEncodable(subscriptionId), AnyEncodable(filter)]
        }
        
        guard let data = try? JSONEncoder().encode(payload) else {
            return nil
        }
        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
