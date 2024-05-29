//
//  MetadataEvent.swift
//  
//
//  Created by Bryan Montz on 7/22/23.
//

import Foundation

/// An object that describes a user.
public struct UserMetadata: Codable {
    
    /// The user's name.
    public let name: String?
    
    /// The user's display name.
    /// > Warning: This property is not part of the Nostr specifications.
    public let displayName: String?

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
        case displayName = "display_name"
    }
    
    public init(name: String?, displayName: String?, about: String?, website: URL?, nostrAddress: String?, pictureURL: URL?, bannerPictureURL: URL?) {
        self.name = name
        self.displayName = displayName
        self.about = about
        self.website = website
        self.nostrAddress = nostrAddress
        self.pictureURL = pictureURL
        self.bannerPictureURL = bannerPictureURL
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
    }
}

/// An event that contains a user profile.
/// 
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/b503f8a92b22be3037b8115fe3e644865a4fa155/01.md#basic-event-kinds)
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
    /// - Parameters:
    ///   - userMetadata: The metadata to set.
    ///   - customEmojis: The custom emojis to emojify with if the matching shortcodes are found in the name or about fields.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed ``MetadataEvent``.
    ///
    /// See [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md)
    func metadataEvent(withUserMetadata userMetadata: UserMetadata, customEmojis: [CustomEmoji] = [], signedBy keypair: Keypair) throws -> MetadataEvent {
        let metadataAsData = try JSONEncoder().encode(userMetadata)
        guard let metadataAsString = String(data: metadataAsData, encoding: .utf8) else {
            throw EventCreatingError.invalidInput
        }
        let customEmojiTags = customEmojis.map { $0.tag }
        return try MetadataEvent(content: metadataAsString, tags: customEmojiTags, signedBy: keypair)
    }
}
