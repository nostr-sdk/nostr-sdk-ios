//
//  MetadataEvent.swift
//  
//
//  Created by Bryan Montz on 7/22/23.
//

import Foundation

/// An object that describes a user.
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/master/01.md#kinds)
@available(*, deprecated, message: "Deprecated in favor of individual tags on MetadataEvent.")
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
public final class MetadataEvent: NostrEvent, CustomEmojiInterpreting, NormalReplaceableEvent {

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    required init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), pubkey: String) {
        super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, pubkey: pubkey)
    }

    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(id: String, pubkey: String, createdAt: Int64, kind: EventKind, tags: [Tag], content: String, signature: String?) {
        super.init(id: id, pubkey: pubkey, createdAt: createdAt, kind: kind, tags: tags, content: content, signature: signature)
    }

    @available(*, deprecated, message: "Deprecated in favor of MetadataEvent.Builder.")
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .metadata, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// A dictionary containing all of the properties in the `content` field of the ``NostrEvent``.
    @available(*, deprecated, message: "Deprecated in favor of tags on MetadataEvent.")
    public var rawUserMetadata: [String: Any] {
        guard let data = content.data(using: .utf8) else {
            return [:]
        }
        let dict = try? JSONSerialization.jsonObject(with: data)
        return dict as? [String: Any] ?? [:]
    }
    
    /// An object that contains decoded user properties from the `content` field of the ``NostrEvent``.
    @available(*, deprecated, message: "Deprecated in favor of tags on MetadataEvent.")
    public var userMetadata: UserMetadata? {
        guard let data = content.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(UserMetadata.self, from: data)
    }

    public var name: String? {
        firstValueForRawTagName("name") ?? userMetadata?.name
    }

    /// The user's display name.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public var displayName: String? {
        firstValueForRawTagName("display_name") ?? userMetadata?.displayName
    }

    /// The user's description of themself.
    public var about: String? {
        firstValueForRawTagName("about") ?? userMetadata?.about
    }

    /// The user's website address.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public var websiteURL: URL? {
        if let website = firstValueForRawTagName("website") {
            return URL(string: website)
        }

        return userMetadata?.website
    }

    /// The user's Nostr address.
    ///
    /// > Note: [NIP-05 Specification](https://github.com/nostr-protocol/nips/blob/master/05.md#finding-users-from-their-nip-05-identifier).
    public var nostrAddress: String? {
        firstValueForRawTagName("nip05") ?? userMetadata?.nostrAddress
    }

    /// A URL to retrieve the user's picture.
    public var pictureURL: URL? {
        if let picture = firstValueForRawTagName("picture") {
            return URL(string: picture)
        }

        return userMetadata?.pictureURL
    }

    /// A URL to retrieve the user's banner image.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public var bannerPictureURL: URL? {
        if let banner = firstValueForRawTagName("banner") {
            return URL(string: banner)
        }

        return userMetadata?.bannerPictureURL
    }

    /// A boolean to clarify that the content is entirely or partially the result of automation, such as with chatbots or newsfeeds.
    /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
    public var isBot: Bool? {
        switch firstValueForRawTagName("bot")?.lowercased() {
        case "true":
            return true
        case "false":
            return false
        case .some:
            return nil
        case .none:
            return userMetadata?.isBot
        }
    }

    /// The user's LUD-06 Lightning URL (LNURL).
    /// > Note: [NIP-57 Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md#protocol-flow)
    public var lightningURLString: String? {
        firstValueForRawTagName("lud06") ?? userMetadata?.lightningURLString
    }

    /// The user's LUD-16 Lightning address.
    /// > Note: [NIP-57 Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md#protocol-flow)
    public var lightningAddress: String? {
        firstValueForRawTagName("lud16") ?? userMetadata?.lightningAddress
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
    @available(*, deprecated, message: "Deprecated in favor of MetadataEvent.Builder.")
    func metadataEvent(withUserMetadata userMetadata: UserMetadata, rawUserMetadata: [String: Any] = [:], customEmojis: [CustomEmoji] = [], signedBy keypair: Keypair) throws -> MetadataEvent {
        try MetadataEvent.Builder()
            .userMetadata(userMetadata, merging: rawUserMetadata)
            .customEmojis(customEmojis)
            .build(signedBy: keypair)
    }
}

public extension MetadataEvent {
    /// Builder of ``MetadataEvent``.
    final class Builder: NostrEvent.Builder<MetadataEvent>, CustomEmojiBuilding {
        public init() {
            super.init(kind: .metadata)
        }

        /// Sets the user metadata by merging ``UserMetadata`` with a dictionary of raw metadata.
        ///
        /// - Parameters:
        ///   - userMetadata: The ``UserMetadata`` to set.
        ///   - rawUserMetadata: The dictionary of raw metadata to set that can contain fields unknown to any implemented NIPs.
        ///
        /// > Note: If `rawUserMetadata` has fields that conflict with `userMetadata`, `userMetadata` fields take precedence.
        @available(*, deprecated, message: "Deprecated in favor of individual tags on MetadataEvent.Builder.")
        public final func userMetadata(_ userMetadata: UserMetadata, merging rawUserMetadata: [String: Any] = [:]) throws -> Self {
            let userMetadataAsDictionary = try userMetadataInternal(userMetadata, merging: rawUserMetadata)

            userMetadataAsDictionary.sorted(by: { $0.key < $1.key }).forEach { key, value in
                if let boolValue = value as? Bool {
                    appendTags(Tag(name: key, value: boolValue ? "true" : "false"))
                } else {
                    appendTags(Tag(name: key, value: String(describing: value)))
                }
            }

            return self
        }

        @discardableResult
        private final func userMetadataInternal(_ userMetadata: UserMetadata, merging rawUserMetadata: [String: Any] = [:]) throws -> [String: Any] {
            let userMetadataAsData = try JSONEncoder().encode(userMetadata)
            var userMetadataAsDictionary = try JSONSerialization.jsonObject(with: userMetadataAsData, options: []) as? [String: Any] ?? [:]
            userMetadataAsDictionary.merge(rawUserMetadata) { (current, _) in current }
            let allUserMetadataAsData: Data = try JSONSerialization.data(withJSONObject: userMetadataAsDictionary, options: .sortedKeys)

            guard let allUserMetadataAsString = String(data: allUserMetadataAsData, encoding: .utf8) else {
                throw EventCreatingError.invalidInput
            }

            content(allUserMetadataAsString)

            return userMetadataAsDictionary
        }

        /// A dictionary containing all of the properties in the `content` field of the ``NostrEvent``.
        private var rawUserMetadata: [String: Any] {
            guard let data = content.data(using: .utf8) else {
                return [:]
            }
            let dict = try? JSONSerialization.jsonObject(with: data)
            return dict as? [String: Any] ?? [:]
        }

        /// The user's name.
        public final func name(_ name: String) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["name"] = name
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "name", value: name))
        }

        /// The user's display name.
        /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
        public final func displayName(_ displayName: String) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["display_name"] = displayName
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "display_name", value: displayName))
        }

        /// The user's description of themself.
        public final func about(_ about: String) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["about"] = about
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "about", value: about))
        }

        /// The user's website address.
        /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
        public final func websiteURL(_ websiteURL: URL) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["website"] = websiteURL.absoluteString
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "website", value: websiteURL.absoluteString))
        }

        /// The user's Nostr address.
        ///
        /// > Note: [NIP-05 Specification](https://github.com/nostr-protocol/nips/blob/master/05.md#finding-users-from-their-nip-05-identifier).
        public final func nostrAddress(_ nostrAddress: String) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["nip05"] = nostrAddress
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "nip05", value: nostrAddress))
        }

        /// A URL to retrieve the user's picture.
        public final func pictureURL(_ pictureURL: URL) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["picture"] = pictureURL.absoluteString
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "picture", value: pictureURL.absoluteString))
        }

        /// A URL to retrieve the user's banner image.
        /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
        public final func bannerPictureURL(_ bannerPictureURL: URL) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["banner"] = bannerPictureURL.absoluteString
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "banner", value: bannerPictureURL.absoluteString))
        }

        /// A boolean to clarify that the content is entirely or partially the result of automation, such as with chatbots or newsfeeds.
        /// > Note: [NIP-24 Extra metadata fields and tags](https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0)
        public final func isBot(_ isBot: Bool) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["bot"] = isBot
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "bot", value: isBot ? "true" : "false"))
        }

        /// The user's LUD-06 Lightning URL (LNURL).
        /// > Note: [NIP-57 Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md#protocol-flow)
        public final func lightningURLString(_ lightningURLString: String) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["lud06"] = lightningURLString
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "lud06", value: lightningURLString))
        }

        /// The user's LUD-16 Lightning address.
        /// > Note: [NIP-57 Lightning Zaps](https://github.com/nostr-protocol/nips/blob/master/57.md#protocol-flow)
        public final func lightningAddress(_ lightningAddress: String) throws -> Self {
            var rawUserMetadata = rawUserMetadata
            rawUserMetadata["lud16"] = lightningAddress
            try userMetadataInternal(UserMetadata(), merging: rawUserMetadata)
            return appendTags(Tag(name: "lud16", value: lightningAddress))
        }
    }
}
