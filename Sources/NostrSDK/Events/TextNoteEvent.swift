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
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Return the first event tag with a reply marker if it exists.
        if let reply = eventTags.first(where: { $0.marker == .reply }) {
            return reply
        }

        // A direct reply to the root of a thread should have a single marked event tag of type "root".
        if let root = eventTags.first(where: { $0.marker == .root }) {
            return root
        }

        // If there are no reply or root event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no reply event tag.
        guard eventTags.allSatisfy({ $0.marker == nil }) else {
            return nil
        }

        // Otherwise, NIP-10 states that the last event tag is the one being responded to.
        return eventTags.last
    }

    /// The ``EventTag`` that denotes the root event of the thread being responded to.
    public var rootEventTag: EventTag? {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Return the first event tag with a root marker if it exists.
        if let root = eventTags.first(where: { $0.marker == .root }) {
            return root
        }

        // If there are no root event markers, and there is at least one event tag with a marker,
        // then we can make a reasonable assumption that the client that created the event does not use
        // deprecated positional event tags, so there is no root event tag.
        guard eventTags.allSatisfy({ $0.marker == nil }) else {
            return nil
        }

        // NIP-10 states that the first event tag is the root.
        return eventTags.first
    }

    /// The ``EventTag``s that denotes quoted or reposted events.
    public var mentionedEventTags: [EventTag] {
        let eventTags = tags.compactMap { EventTag(tag: $0) }

        // Only mention markers are considered mentions in the preferred spec.
        // If there is a mix of mention markers and no markers, the event tags
        // with no markers are ignored.
        let mentionedEventTags = eventTags.filter { $0.marker == .mention }

        if !mentionedEventTags.isEmpty {
            return mentionedEventTags
        }

        // If the event has any event tags with any marker, then we can make a reasonable assummption
        // that the client that created this event does not use deprecated positional event tags,
        // so there are no mentions.
        //
        // Even if there are no event tag markers, the deprecated positional event tag spec in NIP-10
        // states that there are no mentions unless there are 3 or more event tags.
        guard eventTags.allSatisfy({ $0.marker == nil }) && eventTags.count >= 3 else {
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
