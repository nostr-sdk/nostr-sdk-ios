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
public final class BookmarksListEvent: NostrEvent, HashtagInterpreting, PrivateTagInterpreting, ReferenceTagInterpreting, EventCoordinatesTagInterpreting {
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

    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .bookmarksList, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Ids of bookmarked kind-1 notes.
    public var noteIds: [String] {
        allValues(forTagName: .event)
    }
    
    /// Tags with bookmarked kind-1 notes. The returned ``Tag`` objects may contain relay information.
    public var noteTags: [Tag] {
        allTags(withTagName: .event)
    }
    
    /// Coordinates of bookmarked articles.
    public var articlesCoordinates: [EventCoordinates] {
        eventCoordinates
    }
    
    /// Bookmarked links (web URLs).
    public var links: [URL] {
        references
    }
    
    /// The privately bookmarked note ids.
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The note ids.
    public func privateNoteIds(using keypair: Keypair) -> [String] {
        valuesForPrivateTags(from: content, withName: .event, using: keypair)
    }
    
    /// The privately bookmarked note tags. The returned ``Tag`` objects may contain relay information.
    /// - Parameter keypair: The keypair with which to decrypt the content.
    /// - Returns: The note tags.
    public func privateNoteTags(using keypair: Keypair) -> [Tag] {
        privateTags(from: content, withName: .event, using: keypair)
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

public extension EventCreating {

    /// Creates a ``BookmarksListEvent`` (kind 10003) containing an uncategorized, "global" list of things a user wants to save.
    /// - Parameters:
    ///   - publiclyBookmarkedEventIds: Event ids to bookmark.
    ///   - privatelyBookmarkedEventIds: Event ids to privately bookmark.
    ///   - publiclyBookmarkedArticlesCoordinates: Articles coordinates to bookmark.
    ///   - privatelyBookmarkedArticlesCoordinates: Articles coordinates to privately bookmark.
    ///   - publiclyBookmarkedHashtags: Hashtags to bookmark.
    ///   - privatelyBookmarkedHashtags: Hashtags to privately bookmark.
    ///   - publiclyBookmarkedLinks: Links to bookmark.
    ///   - privatelyBookmarkedLinks: Links to privately bookmark.
    ///   - keypair: The Keypair to sign with.
    func bookmarksList(withPubliclyBookmarksEventIds publiclyBookmarkedEventIds: [String] = [],
                       privatelyBookmarkedEventIds: [String] = [],
                       publiclyBookmarkedArticlesCoordinates: [EventCoordinates] = [],
                       privatelyBookmarkedArticlesCoordinates: [EventCoordinates] = [],
                       publiclyBookmarkedHashtags: [String] = [],
                       privatelyBookmarkedHashtags: [String] = [],
                       publiclyBookmarkedLinks: [URL] = [],
                       privatelyBookmarkedLinks: [URL] = [],
                       signedBy keypair: Keypair) throws -> BookmarksListEvent {
        let publicTags: [Tag] = publiclyBookmarkedEventIds.map { .event($0) } +
                                publiclyBookmarkedArticlesCoordinates.map { $0.tag } +
                                publiclyBookmarkedHashtags.map { .hashtag($0) } +
                                publiclyBookmarkedLinks.map { .link($0) }

        let privateTags: [Tag] = privatelyBookmarkedEventIds.map { .event($0) } +
                                 privatelyBookmarkedArticlesCoordinates.map { $0.tag } +
                                 privatelyBookmarkedHashtags.map { .hashtag($0) } +
                                 privatelyBookmarkedLinks.map { .link($0) }

        return try bookmarksList(withPublicTags: publicTags,
                                 privateTags: privateTags,
                                 signedBy: keypair)
    }

    /// Creates a ``BookmarksListEvent`` (kind 10003) containing an uncategorized, "global" list of things a user wants to save from the provided tags.
    /// - Parameters:
    ///   - publicTags: The public tags to bookmark. May include "e" (event id), "t" (hashtag), "a" (event coordinates), and "r" (reference) tags.
    ///   - privateTags: The private tags to bookmark. May include "e" (event id), "t" (hashtag), "a" (event coordinates), and "r" (reference) tags.
    ///   - keypair: The Keypair to sign with.
    /// - Returns: The signed event.
    func bookmarksList(withPublicTags publicTags: [Tag] = [],
                       privateTags: [Tag] = [],
                       signedBy keypair: Keypair) throws -> BookmarksListEvent {
        let validTagNames: Set<TagName> = [.event, .eventCoordinates, .hashtag, .webURL]
        let validRawTagNames = Set(validTagNames.map { $0.rawValue })
        let tagNames: Set<String> = Set((publicTags + privateTags).map { $0.name })

        guard tagNames.isSubset(of: validRawTagNames) else {
            throw EventCreatingError.invalidInput
        }

        var encryptedContent: String?
        if !privateTags.isEmpty {
            let rawPrivateTags = privateTags.map { $0.raw }
            if let unencryptedData = try? JSONSerialization.data(withJSONObject: rawPrivateTags),
               let unencryptedContent = String(data: unencryptedData, encoding: .utf8) {
                encryptedContent = try legacyEncrypt(content: unencryptedContent,
                                                     privateKey: keypair.privateKey,
                                                     publicKey: keypair.publicKey)
            }
        }

        return try BookmarksListEvent(content: encryptedContent ?? "", tags: publicTags, signedBy: keypair)
    }
}
