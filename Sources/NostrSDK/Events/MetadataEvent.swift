//
//  MetadataEvent.swift
//  
//
//  Created by Bryan Montz on 7/22/23.
//

import Foundation

/// An object that describes a user.
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/master/01.md#kinds)
public struct UserMetadata: Codable {
    
    /// The user's name.
    public let name: String?
    
    /// The user's display name.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public let displayName: String?

    /// The user's description of themself.
    public let about: String?
    
    /// The user's website address.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public let website: URL?
    
    /// The user's Nostr address.
    ///
    /// > Note: [NIP-05 Specification](https://github.com/nostr-protocol/nips/blob/master/05.md#finding-users-from-their-nip-05-identifier).
    public let nostrAddress: String?
    
    /// A URL to retrieve the user's picture.
    public let pictureURL: URL?
    
    /// A URL to retrieve the user's banner image.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public let bannerPictureURL: URL?

    /// A boolean to clarify that the content is entirely or partially the result of automation, such as with chatbots or newsfeeds.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public let isBot: Bool?

    /// The user's LUD-06 Lightning URL (LNURL).
    /// > Note: [NIP-57 Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md#protocol-flow)
    public let lightningURLString: String?

    /// The user's LUD-16 Lightning address.
    /// > Note: [NIP-57 Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md#protocol-flow)
    public let lightningAddress: String?

    enum CodingKeys: String, CodingKey {
        case name, about, website
        case nostrAddress = "nip05"
        case pictureURL = "picture"
        case bannerPictureURL = "banner"
        case displayName = "display_name"
        case isBot = "bot"
        case lightningURLString = "lud06"
        case lightningAddress = "lud16"
    }
    
    public init(name: String? = nil, displayName: String? = nil, about: String? = nil, website: URL? = nil, nostrAddress: String? = nil, pictureURL: URL? = nil, bannerPictureURL: URL? = nil, isBot: Bool? = nil, lightningURLString: String? = nil, lightningAddress: String? = nil) {
        self.name = name
        self.displayName = displayName
        self.about = about
        self.website = website
        self.nostrAddress = nostrAddress
        self.pictureURL = pictureURL
        self.bannerPictureURL = bannerPictureURL
        self.isBot = isBot
        self.lightningURLString = lightningURLString
        self.lightningAddress = lightningAddress
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        about = try container.decodeIfPresent(String.self, forKey: .about)
        website = try? container.decodeIfPresent(URL.self, forKey: .website)
        nostrAddress = try container.decodeIfPresent(String.self, forKey: .nostrAddress)
        pictureURL = try? container.decodeIfPresent(URL.self, forKey: .pictureURL)
        bannerPictureURL = try? container.decodeIfPresent(URL.self, forKey: .bannerPictureURL)
        isBot = try? container.decodeIfPresent(Bool.self, forKey: .isBot)
        lightningURLString = try? container.decodeIfPresent(String.self, forKey: .lightningURLString)
        lightningAddress = try? container.decodeIfPresent(String.self, forKey: .lightningAddress)
    }
}

/// An event that contains a user profile.
/// 
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/master/01.md#kinds)
public final class MetadataEvent: NostrEvent, CustomEmojiInterpreting, NonParameterizedReplaceableEvent {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .metadata, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
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

public extension EventCreating {
    
    /// Creates a ``MetadataEvent`` (kind 0) and signs it with the provided ``Keypair``.
    ///
    /// - Parameters:
    ///   - userMetadata: The ``UserMetadata`` to set.
    ///   - rawUserMetadata: The dictionary of raw metadata to set that can contain fields unknown to any implemented NIPs.
    ///   - customEmojis: The custom emojis to emojify with if the matching shortcodes are found in the name or about fields.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``MetadataEvent``.
    ///
    /// > Note: If `rawUserMetadata` has fields that conflict with `userMetadata`, `userMetadata` fields take precedence.
    ///
    /// > Note: [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md)
    func metadataEvent(withUserMetadata userMetadata: UserMetadata, rawUserMetadata: [String: Any] = [:], customEmojis: [CustomEmoji] = [], signedBy keypair: Keypair) throws -> MetadataEvent {
        let userMetadataAsData = try JSONEncoder().encode(userMetadata)

        let allUserMetadataAsData: Data
        if rawUserMetadata.isEmpty {
            allUserMetadataAsData = userMetadataAsData
        } else {
            var userMetadataAsDictionary = try JSONSerialization.jsonObject(with: userMetadataAsData, options: []) as? [String: Any] ?? [:]
            userMetadataAsDictionary.merge(rawUserMetadata) { (current, _) in current }
            allUserMetadataAsData = try JSONSerialization.data(withJSONObject: userMetadataAsDictionary, options: .sortedKeys)
        }

        let allUserMetadataAsString = String(decoding: allUserMetadataAsData, as: UTF8.self)
        let customEmojiTags = customEmojis.map { $0.tag }
        return try MetadataEvent(content: allUserMetadataAsString, tags: customEmojiTags, signedBy: keypair)
    }
}
