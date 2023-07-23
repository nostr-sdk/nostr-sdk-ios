//
//  SetMetadataEvent.swift
//  
//
//  Created by Bryan Montz on 7/22/23.
//

import Foundation

/// An object that describes a user.
public struct UserMetadata: Decodable {
    
    /// The user's name.
    public let name: String?
    
    /// The user's description of themself.
    public let about: String?
    
    /// The user's website address.
    public let website: URL?
    
    /// The user's Nostr address.
    ///
    /// > Note: [NIP-05 Specification](https://github.com/nostr-protocol/nips/blob/master/05.md#nip-05).
    public let nostrAddress: String?
    
    /// A URL to retrieve the user's picture.
    public let pictureURL: URL?
    
    /// A URL to retrieve the user's banner image.
    public let bannerPictureURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case name, about, website
        case nostrAddress = "nip05"
        case pictureURL = "picture"
        case bannerPictureURL = "banner"
    }
}

/// An event that contains a user profile.
/// 
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/b503f8a92b22be3037b8115fe3e644865a4fa155/01.md#basic-event-kinds)
public final class SetMetadataEvent: NostrEvent {
    
    /// A dictionary containing all of the properties in the `content` field of the ``NostrEvent``.
    public var rawUserMetadata: [String: Any] {
        guard let data = content.data(using: .utf8) else {
            return [:]
        }
        let dict = try? JSONSerialization.jsonObject(with: data)
        return dict as? [String: Any] ?? [:]
    }
    
    /// An object that contains decoded user properties from the `content` field of the ``NostrEvent``.
    public var userMetadata: UserMetadata? {
        guard let data = content.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(UserMetadata.self, from: data)
    }
}
