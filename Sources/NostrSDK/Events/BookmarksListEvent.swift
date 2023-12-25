//
//  BookmarksListEvent.swift
//
//
//  Created by Bryan Montz on 12/22/23.
//

import Foundation

/// An event that contains an uncategorized, "global" list of things a user wants to save.
///
/// See [NIP-51](https://github.com/nostr-protocol/nips/blob/master/51.md#standard-lists).
public final class BookmarksListEvent: NostrEvent, HashtagInterpreting, PrivateTagInterpreting {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .bookmarksList, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Ids of bookmarked kind-1 notes.
    public var noteIds: [String] {
        allValues(forTagName: .event) ?? []
    }
    
    /// Coordinates of bookmarked articles.
    public var articlesCoordinates: [EventCoordinates] {
        tags.filter({ $0.name == TagName.eventCoordinates.rawValue }).compactMap { EventCoordinates(eventCoordinatesTag: $0) }
    }
    
    /// Bookmarked links (web URLs).
    public var links: [URL] {
        allValues(forTagName: .webURL)?.compactMap { URL(string: $0) } ?? []
    }
    
    /// The privately bookmarked note ids.
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The note ids.
    public func privateNoteIds(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .event, using: keypair)
    }
    
    /// The privately bookmarked articles coordinates.
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The articles coordinates.
    public func privateArticlesCoordinates(using keypair: Keypair) -> [EventCoordinates] {
        let coordinatesTags = privateTags(from: content, withName: .eventCoordinates, using: keypair)
        return coordinatesTags.compactMap { EventCoordinates(eventCoordinatesTag: $0) }
    }
    
    /// The privately bookmarked hashtags.
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The hashtags.
    public func privateHashtags(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .hashtag, using: keypair)
    }
    
    /// The privately bookmarked links (web URLs).
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The links.
    public func privateLinks(using keypair: Keypair) -> [URL] {
        let urlStrings = valuesForPrivateTags(from: content, withName: .webURL, using: keypair)
        return urlStrings.compactMap { URL(string: $0) }
    }
}
