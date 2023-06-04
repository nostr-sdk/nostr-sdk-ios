//
//  RelayInfo.swift
//  
//
//  Created by Bryan Montz on 6/4/23.
//

import Foundation

// NIP-11 Relay Information Document
// https://github.com/nostr-protocol/nips/blob/master/11.md

public struct RelayInfo: Codable {
    public let name: String?
    public let description: String?
    public let contactPubkey: String?
    public let alternativeContact: String?
    public let supportedNIPs: [Int]?
    public let supportedNIPExtensions: [String]?
    public let software: String?
    public let version: String?
    public let limitations: Limitations?
    public let paymentsURL: String?
    public let fees: Fees?
    public let relayCountries: [String]?
    public let languageTags: [String]?
    public let tags: [String]?
    public let postingPolicyURL: String?
    public let retentionPolicies: [EventRetentionPolicy]?
    
    enum CodingKeys: String, CodingKey {
        case name, description
        case contactPubkey = "pubkey"
        case alternativeContact = "contact"
        case supportedNIPs = "supported_nips"
        case supportedNIPExtensions = "supported_nip_extensions"
        case software, version
        case limitations = "limitation"
        case paymentsURL = "payments_url"
        case fees
        case relayCountries = "relay_countries"
        case languageTags = "language_tags"
        case tags
        case postingPolicyURL = "posting_policy"
        case retentionPolicies = "retention"
    }
    
    public struct Limitations: Codable {
        public let maxMessageLength: Int?
        public let maxSubscriptions: Int?
        public let maxFilters: Int?
        public let maxLimit: Int?
        public let maxSubscriptionIdLength: Int?
        public let minPrefix: Int?
        public let maxEventTags: Int?
        public let maxContentLength: Int?
        public let minProofOfWorkDifficulty: Int?
        public let isAuthenticationRequired: Bool?
        public let isPaymentRequired: Bool?
        
        enum CodingKeys: String, CodingKey {
            case maxMessageLength = "max_message_length"
            case maxSubscriptions = "max_subscriptions"
            case maxFilters = "max_filters"
            case maxLimit = "max_limit"
            case maxSubscriptionIdLength = "max_subid_length"
            case minPrefix = "min_prefix"
            case maxEventTags = "max_event_tags"
            case maxContentLength = "max_content_length"
            case minProofOfWorkDifficulty = "min_pow_difficulty"
            case isAuthenticationRequired = "auth_required"
            case isPaymentRequired = "payment_required"
        }
    }
    
    public struct Fee: Codable {
        public let kinds: [Int]?
        public let amount: Int?
        public let unit: String?
        public let period: Int?
    }
    
    public struct Fees: Codable {
        public let admission: [Fee]?
        public let subscription: [Fee]?
        public let publication: [Fee]?
    }
    
    public struct EventRetentionPolicy: Codable {
        public let time: Int?
        public let count: Int?
        public let kindRanges: [ClosedRange<Int>]?
        
        enum CodingKeys: String, CodingKey {
            case time, count
            case kindRanges = "kinds"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            time = try container.decodeIfPresent(Int.self, forKey: .time)
            count = try container.decodeIfPresent(Int.self, forKey: .count)
            
            if container.contains(.kindRanges) {
                var kindRanges = [ClosedRange<Int>]()
                var kindsContainer = try container.nestedUnkeyedContainer(forKey: .kindRanges)
                while !kindsContainer.isAtEnd {
                    if let intValue = try? kindsContainer.decode(Int.self) {
                        kindRanges.append(intValue...intValue)
                    } else if let intArray = try? kindsContainer.decode([Int].self) {
                        if intArray.count == 2 {
                            kindRanges.append(intArray[0]...intArray[1])
                        } else {
                            break // invalid data, fail silently since retention data is optional
                        }
                    } else {
                        break   // invalid data
                    }
                }
                self.kindRanges = kindRanges
            } else {
                kindRanges = nil
            }
        }
        
        public func governsKind(_ kind: Int) -> Bool {
            kindRanges?.contains(where: { $0.contains(kind) }) ?? false
        }
    }
    
    public func retentionPolicy(forKind kind: Int) -> EventRetentionPolicy? {
        retentionPolicies?.first(where: { $0.governsKind(kind) }) ?? retentionPolicies?.first(where: { $0.kindRanges == nil })
    }
}
