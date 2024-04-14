//
//  LongformContentEvent.swift
//
//
//  Created by Bryan Montz on 11/2/23.
//

import Foundation

/// A long-form content event (kind 30023, a parameterized replaceable event) is for long-form text content, generally referred to as "articles" or "blog posts".
///
/// > Important: The `content` of these events should be a string text in Markdown syntax. To maximize compatibility and readability between different clients and devices, any client that is creating long-form notes:
///              * MUST NOT hard line-break paragraphs of text, such as arbitrary line breaks at 80 column boundaries.
///              * MUST NOT support adding HTML to Markdown.
///
/// > Note: [NIP-23 Specification](https://github.com/nostr-protocol/nips/blob/master/23.md)
public final class LongformContentEvent: NostrEvent, HashtagInterpreting, ParameterizedReplaceableEvent, TitleTagInterpreting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .longformContent, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// The date of the first time the article was published.
    var publishedAt: Date? {
        guard let unixTimeString = firstValueForTagName(.publishedAt),
              let unixSeconds = TimeInterval(unixTimeString) else {
            return nil
        }
        return Date(timeIntervalSince1970: unixSeconds)
    }

    /// A summary of the content.
    var summary: String? {
        firstValueForTagName(.summary)
    }
    
    /// A URL pointing to an image to be shown along with the title.
    var imageURL: URL? {
        guard let imageURLString = firstValueForTagName(.image) else {
            return nil
        }
        return URL(string: imageURLString)
    }
}

public extension EventCreating {

    /// Creates a ``LongformContentEvent`` (kind 30023, a parameterized replaceable event) for long-form text content, generally referred to as "articles" or "blog posts".
    /// - Parameters:
    ///   - identifier: A unique identifier for the content. Can be reused in the future for replacing the event. If an identifier is not provided, a ``UUID`` string is used.
    ///   - title: The article title.
    ///   - markdownContent: A string text in Markdown syntax.
    ///   - summary: A summary of the content.
    ///   - imageURL: A URL pointing to an image to be shown along with the title.
    ///   - hashtags: An optional list of topics about which the event might be of relevance.
    ///   - publishedAt: The date of the first time the article was published.
    ///   - keypair: The ``Keypair`` to sign with.
    /// - Returns: The signed ``LongformContentEvent``.
    func longformContentEvent(withIdentifier identifier: String = UUID().uuidString,
                              title: String? = nil,
                              markdownContent: String,
                              summary: String? = nil,
                              imageURL: URL? = nil,
                              hashtags: [String]? = nil,
                              publishedAt: Date = .now,
                              signedBy keypair: Keypair) throws -> LongformContentEvent {
        var tags = [Tag]()

        tags.append(Tag(name: .identifier, value: identifier))

        if let title {
            tags.append(Tag(name: .title, value: title))
        }

        if let summary {
            tags.append(Tag(name: .summary, value: summary))
        }

        if let imageURL {
            tags.append(Tag(name: .image, value: imageURL.absoluteString))
        }

        if let hashtags {
            for hashtag in hashtags {
                tags.append(.hashtag(hashtag))
            }
        }

        tags.append(Tag(name: .publishedAt, value: String(Int64(publishedAt.timeIntervalSince1970))))

        return try LongformContentEvent(content: markdownContent, tags: tags, signedBy: keypair)
    }
}
