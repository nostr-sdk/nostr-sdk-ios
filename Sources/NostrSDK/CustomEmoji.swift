//
//  CustomEmoji.swift
//
//
//  Created by Terry Yiu on 11/11/23.
//

import Foundation

/// [NIP-30 Custom Emoji](https://github.com/nostr-protocol/nips/blob/master/30.md)
public class CustomEmoji: CustomEmojiValidating, Equatable {
    public static func == (lhs: CustomEmoji, rhs: CustomEmoji) -> Bool {
        lhs.shortcode == rhs.shortcode &&
        lhs.imageURL == rhs.imageURL
    }

    /// A name given for the emoji, which MUST be comprised of only alphanumeric characters and underscores.
    public let shortcode: String

    /// A URL to the corresponding image file of the emoji.
    public let imageURL: URL

    /// ``Tag`` representation of the custom emoji.
    public var tag: Tag {
        Tag(name: .emoji, value: shortcode, otherParameters: [imageURL.absoluteString])
    }

    /// Creates a ``CustomEmoji`` or returns nil if shortcode is invalid.
    /// - Parameters:
    ///   - shortcode: A name given for the emoji, which MUST be comprised of only alphanumeric characters and underscores.
    ///   - imageURL: A URL to the corresponding image file of the emoji.
    public init?(shortcode: String, imageURL: URL) {
        self.shortcode = shortcode
        self.imageURL = imageURL

        guard isValidShortcode(shortcode) else {
            return nil
        }
    }
}

/// Builder that adds ``CustomEmoji``s to a ``NostrEvent``.
public protocol CustomEmojiBuilding: NostrEventBuilding {}
public extension CustomEmojiBuilding {
    /// Adds a list of ``CustomEmoji``.
    @discardableResult
    func customEmojis(_ customEmojis: [CustomEmoji]) -> Self {
        appendTags(contentsOf: customEmojis.map { $0.tag })
    }
}

public protocol CustomEmojiInterpreting: NostrEvent, CustomEmojiValidating {}
public extension CustomEmojiInterpreting {
    /// Returns the list of well-formatted custom emojis derived from NostrEvent tags.
    /// It does not fetch images from the specified URLs to determine if they exist.
    var customEmojis: [CustomEmoji] {
        return tags.compactMap { tag in
            guard tag.name == TagName.emoji.rawValue, !tag.otherParameters.isEmpty, let imageURLString = tag.otherParameters.first, let imageURL = URL(string: imageURLString) else {
                return nil
            }

            return CustomEmoji(shortcode: tag.value, imageURL: imageURL)
        }
    }
}

public protocol CustomEmojiValidating {}
public extension CustomEmojiValidating {
    /// Returns true if a custom emoji shortcode is valid (comprised of only alphanumeric characters and underscores)..
    func isValidShortcode(_ shortcode: String) -> Bool {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "\\A[_0-9a-zA-Z]+\\z")
        } catch {
            return false
        }

        return !regex.matches(in: shortcode, range: NSRange(location: 0, length: shortcode.count)).isEmpty
    }
}
