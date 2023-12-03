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
public final class LongformContentEvent: NostrEvent, HashtagInterpreting {
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
        guard let unixTimeString = valueForTagName(.publishedAt),
              let unixSeconds = TimeInterval(unixTimeString) else {
            return nil
        }
        return Date(timeIntervalSince1970: unixSeconds)
    }
    
    /// A unique identifier for the content. Can be reused in the future for replacing the event.
    var identifier: String? {
        valueForTagName(.identifier)
    }
    
    /// The article title.
    var title: String? {
        valueForTagName(.title)
    }
    
    /// A summary of the content.
    var summary: String? {
        valueForTagName(.summary)
    }
    
    /// A URL pointing to an image to be shown along with the title.
    var imageURL: URL? {
        guard let imageURLString = valueForTagName(.image) else {
            return nil
        }
        return URL(string: imageURLString)
    }
}
