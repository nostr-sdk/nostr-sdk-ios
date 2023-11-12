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
        lhs.isEqual(to: rhs)
    }

    /// A name given for the emoji, which MUST be comprised of only alphanumeric characters and underscores.
    let shortcode: String

    /// A a URL to the corresponding image file of the emoji.
    let imageUrl: URL

    init?(shortcode: String, imageUrl: URL) {
        self.shortcode = shortcode
        self.imageUrl = imageUrl

        if !isValidShortcode(shortcode: shortcode) {
            return nil
        }
    }

    func tag() -> Tag {
        Tag(name: .emoji, value: shortcode, otherParameters: [imageUrl.absoluteString])
    }

    func isEqual(to customEmoji: CustomEmoji) -> Bool {
        shortcode == customEmoji.shortcode &&
        imageUrl == customEmoji.imageUrl
    }
}

public protocol CustomEmojiInterpreting: NostrEvent, CustomEmojiValidating {}
public extension CustomEmojiInterpreting {
    /// Returns the list of well-formatted custom emojis derived from NostrEvent tags.
    /// It does not fetch images from the specified URLs to determine if they exist.
    var customEmojis: [CustomEmoji] {
        return tags.compactMap { tag in
            guard tag.name == .emoji, !tag.otherParameters.isEmpty, let imageUrlString = tag.otherParameters.first, let imageUrl = URL(string: imageUrlString) else {
                return nil
            }

            return CustomEmoji(shortcode: tag.value, imageUrl: imageUrl)
        }
    }
}

public protocol CustomEmojiValidating {}
public extension CustomEmojiValidating {
    /// Returns true if a custom emoji shortcode is valid (comprised of only alphanumeric characters and underscores)..
    func isValidShortcode(shortcode: String) -> Bool {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "/\\A[_0-9a-zA-Z]+\\z/")
        } catch {
            return false
        }

        guard regex.matches(in: shortcode, range: NSRange(location: 0, length: shortcode.count)).isEmpty else {
            return false
        }

        return true
    }
}
