//
//  TextNoteEvent.swift
//  
//
//  Created by Bryan Montz on 7/23/23.
//

import Foundation

/// An event that contains plaintext content.
///
/// > Note: [NIP-01 Specification](https://github.com/nostr-protocol/nips/blob/b503f8a92b22be3037b8115fe3e644865a4fa155/01.md#basic-event-kinds)
public final class TextNoteEvent: NostrEvent, CustomEmojiInterpreting {
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    @available(*, unavailable, message: "This initializer is unavailable for this class.")
    override init(kind: EventKind, content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: kind, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    init(content: String, tags: [Tag] = [], createdAt: Int64 = Int64(Date.now.timeIntervalSince1970), signedBy keypair: Keypair) throws {
        try super.init(kind: .textNote, content: content, tags: tags, createdAt: createdAt, signedBy: keypair)
    }
    
    /// Pubkeys mentioned in the note content.
    public var mentionedPubkeys: [String] {
        allValues(forTagName: .pubkey)
    }
    
    /// Events mentioned in the note content.
    public var mentionedEventIds: [String] {
        allValues(forTagName: .event)
    }

    /// The ``EventTag`` that denotes the reply event being responded to.
    /// This event tag may be the same as ``rootEventTag`` if this note is a direct reply to the root of a thread.
    public var replyEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(eventTag: $0) }
        var rootEventTag: EventTag?

        // Track whether the event has any event tags with a marker as a proxy indicator
        // that the client that created this event uses deprecated positional event tags or not.
        var hasMarker = false

        for eventTag in eventTags {
            let marker = eventTag.marker

            if !hasMarker && marker != nil {
                hasMarker = true
            }

            // Return the first event tag with a reply marker if it exists.
            if marker == .reply {
                return eventTag
            }

            if rootEventTag == nil && marker == .root {
                rootEventTag = eventTag
            }
        }

        // A direct reply to the root of a thread should have a single marked event tag of type "root".
        if let rootEventTag {
            return rootEventTag
        }

        // If there are no reply event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no reply event tag.
        guard !hasMarker else {
            return nil
        }

        // Otherwise, NIP-10 states that the last event tag is the one being responded to.
        return eventTags.last
    }

    /// The ``EventTag`` that denotes the root event of the thread being responded to.
    public var rootEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(eventTag: $0) }

        // Track whether the event has any event tags with a marker as a proxy indicator
        // that the client that created this event uses deprecated positional event tags or not.
        var hasMarker = false

        for eventTag in eventTags {
            let marker = eventTag.marker

            if !hasMarker && marker != nil {
                hasMarker = true
            }

            // Return the first event tag with a root marker if it exists.
            if marker == .root {
                return eventTag
            }
        }

        // If there are no root event markers and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no root event tag.
        guard !hasMarker else {
            return nil
        }

        // NIP-10 states that the first event tag is the root.
        return eventTags.first
    }

    /// The ``EventTag``s that denotes quoted or reposted events.
    public var mentionedEventTags: [EventTag] {
        let eventTags = tags.compactMap { EventTag(eventTag: $0) }
        var mentionedEventTags: [EventTag] = []

        // Track whether the event has any event tags with a marker as a proxy indicator
        // that the client that created this event uses deprecated positional event tags or not.
        var hasMarker = false

        for eventTag in eventTags {
            let marker = eventTag.marker

            if marker != nil {
                hasMarker = true
            }

            // Only mention markers are considered mentions in the preferred spec.
            // If there is a mix of mention markers and no markers, the event tags
            // with no markers are ignored.
            if marker == .mention {
                mentionedEventTags.append(eventTag)
            }
        }

        if !mentionedEventTags.isEmpty {
            return mentionedEventTags
        }

        // The deprecated positional event tag spec in NIP-10 states that there are no mentions
        // unless there are 3 or more event tags.
        guard !hasMarker && eventTags.count >= 3 else {
            return []
        }

        // The first event tag is the root and the last event tag is the one being replied to.
        // Everything else in between is a mention.
        return eventTags.dropFirst().dropLast()
    }

    /// a short subject for a text note, similar to subjects in emails.
    ///
    /// See [NIP-14 - Subject tag in Text events](https://github.com/nostr-protocol/nips/blob/master/14.md).
    public var subject: String? {
        firstValueForTagName(.subject)
    }
}
