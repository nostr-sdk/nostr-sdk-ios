//
//  ChannelMetadata.swift
//
//
//  Created by Konstantin Yurchenko, Jr on 9/20/24.
//

import Foundation

/// A structure that describes channel.
///
/// See [NIP-28 Specification](https://github.com/nostr-protocol/nips/blob/master/28.md#kind-40-create-channel).
public struct ChannelMetadata: Codable {
    /// Channel name
    public let name: String?
    /// Channel desctription
    public let about: String?
    /// URL of channel picture
    public let picture: String?
    /// List of relays to download and broadcast events to
    public let relays: [String]?

    enum CodingKeys: String, CodingKey {
        case name
        case about
        case picture
        case relays
    }
    
    public init(name: String? = nil, about: String? = nil, picture: String? = nil, relays: [String] = []) {
        self.name = name
        self.about = about
        self.picture = picture
        self.relays = relays
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decodeIfPresent(String.self, forKey: .name)
        about = try container.decodeIfPresent(String.self, forKey: .about)
        picture = try container.decodeIfPresent(String.self, forKey: .picture)
        relays = try container.decodeIfPresent([String].self, forKey: .relays)
    }
}
